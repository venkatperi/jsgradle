_ = require 'lodash'
rek = require 'rekuire'
Plugin = require './Plugin'
SourceSetContainer = rek 'SourceSetContainer'
FilesSpec = rek 'FilesSpec'
SourceSetOutput = rek 'SourceSetOutput'
CleanMainOutputTask = rek 'CleanMainOutputTask'
TaskFactory = rek 'TaskFactory'
GulpTask = rek 'GulpTask'
assert = require 'assert'
configurable = rek 'configurable'
conf = rek 'conf'

class GulpCompilePlugin extends Plugin

  _createExt : =>
    ext = configurable @project.callScriptMethod
    _.extend ext, conf.get "plugin:#{@name}:options", {}

  _createCompileTask : ( opts ) =>
    options = @project.extensions.get @name
    output = @project.getSourceSets().get("main.output.#{@name}").dir
    spec = @project.getSourceSets().get "main.#{@name}"

    _opts = _.extend {}, opts
    _.extend _opts,
      options : options,
      gulpType : @gulpType
      output : output
      spec : spec
    new GulpTask _opts

  doApply : =>
    assert @gulpType, 'Missing option: gulpType'
    @applyPlugin 'build'
    @applyPlugin 'sourceSets'

    upperName = _.upperFirst @name
    conventionName = upperName + 'Convention'
    conventionKlass = require "./#{@name}/#{conventionName}"
    compileTaskType = 'Compile' + upperName
    compileTaskName = 'compile' + upperName
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
    @createTask cleanTaskName, type : cleanTaskType
    @task('build').dependsOn compileTaskName
    @task('clean').dependsOn cleanTaskName

module.exports = GulpCompilePlugin