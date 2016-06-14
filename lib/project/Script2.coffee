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
Clock = rek 'Clock'
{isFile, readFile} = rek 'fileOps'

class Script extends FactoryBuilderSupport
  constructor : ( opts = {} ) ->
    @buildDir = opts.buildDir or process.cwd()
    @continueOnError = opts.continueOnError
    @tasks = opts.tasks
    @totalTime = new Clock()
    super()
    @phase = Phase.Initial
    @registerFactory 'project', new ProjectFactory script : @
    @registerFactory 'task', new TaskBuilderFactory script : @
    @registerFactory 'from', new CopySpecFactory script : @
    @registerFactory 'into', new CopySpecFactory script : @
    @registerFactory 'filter', new CopySpecFactory script : @

  seq : ( f ) =>
    @_seqx ?= seqx()
    @_done = @_seqx.add f
    .fail ( err ) =>
      throw err
      #@emit 'error', err
      @errors ?= []
      @errors.push err

  configure : =>
    out.eolThen 'Configuring... '
    @_configure()
    out.grey(" DONE. #{@totalTime.pretty}").eol()

  #@project.configured

  execute : => @seq @_execute

  report : =>
    @project.report()
    out.eolThen('').eol().white("Total time: #{@totalTime.pretty}").eol()

  _loadScript : =>
    walkup 'build.kohi', cwd : @buildDir
    .then ( v ) =>
      throw new Error "Didn't find file build.kohi" unless v.length
      @scriptFile = path.join v[ 0 ].dir, v[ 0 ].files[ 0 ]
      log.v 'script file:', @scriptFile
      isFile @scriptFile
    .then ( type ) =>
      throw new Error "Not a file: #{@scriptFile}" unless type
      readFile @scriptFile, 'utf8'
    .then ( contents ) =>
      @_createProjectClosure contents

  _createProjectClosure : ( contents ) =>
    # add project closure 
    parts = path.parse @scriptFile
    projectDir = parts.dir
    name = path.basename projectDir
    lines = contents.split '\n'
    lines = ('  ' + l for l in lines)
    lines.splice 0, 0, "project '#{name}', projectDir: '#{projectDir}', ->"
    contents = lines.join '\n'
    @contents = contents

  initialize : =>
    log.v 'initialize'
    @phase = Phase.Initialization
    @_loadScript()

  _configure : =>
    log.v 'configure'
    clock = new Clock()
    @phase = Phase.Configuration
    @evaluate @contents, coffee : true
    @project._tasksToExecute = @tasks if @tasks?.length
    log.v 'configure done:', clock.pretty

  _execute : =>
    log.v 'execute'
    @phase = Phase.Execution
    @project.execute()

module.exports = Script

