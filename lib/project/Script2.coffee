Q = require 'q'
path = require 'path'
fs = require 'fs'
{FactoryBuilderSupport} = require 'coffee-dsl'
walkup = require 'node-walkup'
rek = require 'rekuire'
Phase = rek 'ScriptPhase'
Project = rek 'Project'
out = rek 'lib/util/out'
TaskBuilderFactory = rek 'lib/factory/TaskBuilderFactory'
ProjectFactory = rek 'lib/factory/ProjectFactory'
CopySpecFactory = rek 'lib/factory/CopySpecFactory'
OptionsFactory = rek 'lib/factory/OptionsFactory'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
{isFile, readFile} = rek 'fileOps'
time = rek 'time'
HrTime = rek 'HrTime'
Clock = rek 'Clock'
conf = rek 'conf'

defaultFactories =
  project : ProjectFactory
  task : TaskBuilderFactory
  from : CopySpecFactory
  into : CopySpecFactory
  filter : CopySpecFactory
  options : OptionsFactory

class Script extends FactoryBuilderSupport

  constructor : ( opts = {} ) ->
    @totalTime = new Clock()
    super opts
    @phase = Phase.Initial
    @buildDir = opts.buildDir or conf.get('script:build:dir')
    @continueOnError = opts.continueOnError or conf.get 'project:build:continueOnError'
    @tasks = opts.tasks
    @_registerFactories()

  initialize : =>
    @phase = Phase.Initialization
    @_loadScript()

  configure : =>
    out.eolThen 'Configuring... '
    @_configure()
    out.ifNewline("> Configuring...")
    .grey(" DONE. #{@totalTime.pretty}").eol()

  execute : =>
    @phase = Phase.Execution
    @project.execute()

  report : =>
    @project.report()
    out.eolThen('').eol().white("Total time: #{@totalTime.pretty}").eol()

  _configure : =>
    @phase = Phase.Configuration
    Q.try =>
      @evaluate @contents, coffee : true
      @project._tasksToExecute = @tasks if @tasks?.length

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

