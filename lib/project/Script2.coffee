_ = require 'lodash'
Q = require 'q'
path = require 'path'
fs = require 'fs'
{FactoryBuilderSupport} = require 'coffee-dsl'
walkup = require 'node-walkup'
seqx = require 'seqx'

rek = require 'rekuire'
Phase = rek 'ScriptPhase'
Project = rek 'Project'
out = rek 'lib/util/out'
TaskBuilderFactory = rek 'lib/factory/TaskBuilderFactory'
ProjectFactory = rek 'lib/factory/ProjectFactory'
CopySpecFactory = rek 'lib/factory/CopySpecFactory'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

readFile = Q.denodeify fs.readFile

class Script extends FactoryBuilderSupport
  constructor : ( {@scriptFile} = {} ) ->
    throw new Error "Missing option: scriptFile" unless @scriptFile
    super()
    @phase = Phase.Initial
    @registerFactory 'project', new ProjectFactory script: @
    @registerFactory 'task', new TaskBuilderFactory script: @
    @registerFactory 'from', new CopySpecFactory script: @
    @registerFactory 'into', new CopySpecFactory script: @
    @registerFactory 'filter', new CopySpecFactory script: @
    @seq @_loadScript

  seq : ( f ) =>
    @_seqx ?= seqx()
    @_done = @_seqx.add f
    .fail ( err ) =>
      throw err
      #@emit 'error', err
      @errors ?= []
      @errors.push err

  methodMissing : ( name ) => ( args... ) =>
    log.v "method missing: #{name}, #{JSON.stringify args}"
    val = @project.methodMissing name, args...
    return val if val?
    return [ name ] unless args.length
    args = args[ 0 ] if args.length is 1
    [ name, args ]

  propertyMissing : ( name ) ->
    log.d "property missing: #{name}"
    name

  initialize : => @seq @_initialize

  configure : => @seq @_configure

  execute : => @seq @_execute

  report : => @project.report()

  logLevel : ( l ) => log.level l

  #hasProperty : ( name ) =>
  #  @project?.hasProperty(name) or super(name)
  #
  #hasMethod : ( name ) =>
  #  @project?.hasMethod(name) or super(name)
  #
  #getProperty : ( name ) =>
  #  @project?.getProperty(name) or super(name)
  #
  #setProperty : ( name, val ) =>
  #  @project?.setProperty name, val
  #
  #invokeMethod : ( name, args ) =>
  #  log.i 'invokeMethod', name, args
  #  if @project and name in [ 'apply', 'defaultTasks', 'task' ]
  #    return @project[ name ].apply @project, args
  #  super name, args

  _loadScript : =>
    walkup 'build.kohi', cwd : process.cwd()
    .then ( v ) =>
      throw new Error "Didn't find file build.kohi" unless v.length
      @scriptFile = path.join v[ 0 ].dir, v[ 0 ].files[ 0 ]
      log.v 'script file:', @scriptFile
      readFile @scriptFile, 'utf8'
    .then ( contents ) =>
      # add project closure 
      parts = path.parse @scriptFile
      projectDir = parts.dir
      name = path.basename projectDir
      lines = contents.split '\n'
      lines = ('  ' + l for l in lines)
      lines.splice 0, 0, "project '#{name}', projectDir: '#{projectDir}', ->"
      contents = lines.join '\n'
      @contents = contents

  _initialize : =>
    log.v 'initialize'
    @phase = Phase.Initialization
    #@project = @_createProject()
    #@context.push @project
    #@project.initialize()

  _createProject : =>
    parts = path.parse @scriptFile
    projectDir = parts.dir
    name = path.basename projectDir
    project = new Project
      script : @
      name : name,
      projectDir : projectDir
    project

  _configure : =>
    log.v 'configure'
    @phase = Phase.Configuration
    @evaluate @contents, coffee : true
    #@project.configure()

  _execute : =>
    log.v 'execute'
    @phase = Phase.Execution
    @project.execute()

module.exports = Script

#class Script2 extends FactoryBuilderSupport
#  constructor : ( opts = {} ) ->
#    super()

#module.exports = Script

#code = """
#task copy, type: Copy, -> println 'configuring task'
#
#"""
#
#builder = new Script2().build code, coffee : true

