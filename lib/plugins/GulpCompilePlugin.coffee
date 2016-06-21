_ = require 'lodash'
rek = require 'rekuire'
Plugin = require './Plugin'
SourceSetContainer = rek 'SourceSetContainer'
SourceMapConvention = rek 'SourceMapConvention'
FilesSpec = rek 'FilesSpec'
SourceSetOutput = rek 'SourceSetOutput'
CleanMainOutputTask = rek 'CleanMainOutputTask'
TaskFactory = rek 'TaskFactory'
GulpTask = rek 'GulpTask'
assert = require 'assert'
configurable = rek 'configurable'
conf = rek 'conf'
path = require 'path'
prop = rek 'prop'

class GulpCompilePlugin extends Plugin

  prop @, 'config', get : ->
    conf.get "plugins:#{@name}"

  _generateConventionClass : =>
    upperName = _.upperFirst @name
    genDir = @project.genDir
    outFile = path.join genDir, "#{upperName}Convention.coffee"
    @project.templates.generate 'GulpConventionClass', { name : upperName }, outFile
    require outFile

  _createExt : =>
    ext = configurable @project.callScriptMethod
    _.extend ext, @config.options, {}

  _createCompileTask : ( opts ) =>
    output = @project.getSourceSets().get("main.output.#{@name}").dir
    spec = @project.getSourceSets().get "main.#{@name}"

    taskOptions = _.omit @config, 'uses'
    taskOptions.options ?= {}
    _.extend taskOptions.options, @project.extensions.get @name
    new GulpTask _.extend {}, opts, taskOptions,
      output : output
      spec : spec

  doApply : =>
    @applyPlugin 'build'
    @applyPlugin 'sourceSets'

    upperName = _.upperFirst @name
    conventionKlass = @_generateConventionClass()
    compileTaskType = 'Compile' + upperName
    compileTaskName = 'compile' + upperName
    clearCacheTaskName = 'clearCache' + _.upperFirst(compileTaskName)
    cleanTaskType = 'Clean' + upperName
    cleanTaskName = 'clean' + upperName

    obj =
      extensions : {}
      conventions : {}
      taskFactory : {}
    obj.extensions[ @name ] = @_createExt()
    obj.conventions[ @name ] = conventionKlass
    obj.taskFactory[ compileTaskType ] = @_createCompileTask
    obj.taskFactory[ cleanTaskType ] = CleanMainOutputTask
    @register obj

    @createTask compileTaskName, type : compileTaskType
    @createTask clearCacheTaskName,
      type : 'ClearCacheTask', target : compileTaskName
    @createTask cleanTaskName, type : cleanTaskType
    @task('build').dependsOn compileTaskName
    @task('clean').dependsOn cleanTaskName

module.exports = GulpCompilePlugin