_ = require 'lodash'
Q = require 'q'
path = require 'path'
fs = require 'fs'
{FactoryBuilderSupport} = require 'coffee-dsl'
walkup = require 'node-walkup'
rek = require 'rekuire'
Project = rek 'Project'
out = rek 'lib/util/out'
TaskBuilderFactory = rek 'lib/factory/TaskBuilderFactory'
ProjectFactory = rek 'lib/factory/ProjectFactory'
CopySpecFactory = rek 'lib/factory/CopySpecFactory'
OptionsFactory = rek 'lib/factory/OptionsFactory'
{isFile, readFile} = rek 'fileOps'
time = rek 'time'
HrTime = rek 'HrTime'
Clock = rek 'Clock'
conf = rek 'conf'
ConsoleReporter = rek 'ConsoleReporter'
prop = rek 'prop'

defaultFactories =
  project : ProjectFactory
  task : TaskBuilderFactory
  from : CopySpecFactory
  into : CopySpecFactory
  filter : CopySpecFactory
  options : OptionsFactory

class Script extends FactoryBuilderSupport

  prop @, 'failed', get : ->
    @errors.length or @project.failed

  prop @, 'messages', get : ->
    list = _.map @errors, ( x ) -> '> ' + x.message
    list = _.concat list, @project?.messages
    list.join '\n'

  constructor : ( opts = {} ) ->
    @totalTime = new Clock()
    @errors = []
    @reporters = [ new ConsoleReporter() ]
    @listenTo @
    super opts
    @buildDir = opts.buildDir or conf.get('script:build:dir')
    @continueOnError = opts.continueOnError or conf.get 'project:build:continueOnError'
    @tasks = opts.tasks
    @_registerFactories()
    @mode ?= 'debug'
    @on 'error', ( err ) =>  
      if @mode is 'debug'
        console.log err.stack

  build : ( stage = 'execute' ) =>
    @.initialize().then =>
      @configure()
      .then =>
        return if stage is @stage
        return if @failed
        @afterEvaluate()
      .then =>
        return if stage is @stage
        return if @failed
        @execute()
      .fail ( err ) =>
        console.log err
        @errors.push err
    .then => @report()

  listenTo : ( obj ) =>
    @reporters.forEach ( r ) -> r.listenTo obj

  initialize : =>
    @stage = 'initialize'
    @emit 'script:initialize:start', @
    @_loadScript()
    .finally =>
      @emit 'script:initialize:end', @, @totalTime.pretty

  configure : =>
    @stage = 'configure'
    clock = new Clock()
    @emit 'script:configure:start', @
    @_configure()
    .finally =>
      @emit 'script:configure:end', @, clock.pretty

  afterEvaluate : =>
    @stage = 'afterEvaluate'
    clock = new Clock()
    @emit 'script:afterEvaluate:start', @
    @project.afterEvaluate()
    .finally =>
      @emit 'script:afterEvaluate:end', @, clock.pretty

  execute : =>
    @stage = 'execute'
    @emit 'script:execute:start', @
    @project.execute()
    .finally =>
      @emit 'script:execute:end', @, @totalTime.pretty

  report : =>
    if @failed
      if @errors.length
        out.eolThen().eol()
        .red('FAILURE: The following error(s) occurred:')
        .eol()
        out.grey(@messages).eol()
      else
        @project.report()
    else
      @project.report()

    out.eolThen('').eol().white("Total time: #{@totalTime.pretty}").eol()

  _configure : =>
    Q.try =>
      @evaluate @contents, coffee : true
      @project._tasksToExecute = @tasks if @tasks?.length
    .fail ( err ) =>
      console.log err
      @errors.push err

  _loadScript : =>
    fileName = conf.get 'script:build:file'
    enc = conf.get 'script:build:enc'
    walkup fileName, cwd : @buildDir
    .then ( v ) =>
      throw new Error "Didn't find build file (#{fileName})" unless v.length
      @scriptFile = path.join v[ 0 ].dir, v[ 0 ].files[ 0 ]
      isFile @scriptFile
    .then ( isAFile ) =>
      throw new Error "Not a file: #{@scriptFile}" unless isAFile
      readFile @scriptFile, enc
    .then ( contents ) =>
      @_createProjectClosure contents

  _createProjectClosure : ( contents ) =>
    parts = path.parse @scriptFile
    projectDir = parts.dir
    name = path.basename projectDir
    lines = contents.split '\n'
    lines = ('  ' + l for l in lines)
    lines.splice 0, 0, "project '#{name}', projectDir: '#{projectDir}', ->"
    contents = lines.join '\n'
    @contents = contents

  _registerFactories : =>
    for own k,v of defaultFactories
      @registerFactory k, new v script : @

module.exports = Script

