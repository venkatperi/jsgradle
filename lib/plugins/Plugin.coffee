_ = require 'lodash'
rek = require 'rekuire'
TaskFactory = rek 'TaskFactory'
BaseObject = rek 'BaseObject'

toObj = ( x, opts ) ->
  if _.isFunction(x) then new x(opts) else x

class Plugin extends BaseObject

  @_addProperties
    required : [ 'name' ]
    optional : [ 'description' ]

  apply : ( project ) =>
    return if @configured
    @configured = true
    @project = project
    @doApply()

  applyPlugin : ( name ) =>
    @project.apply plugin : name

  getSourceSet : ( name ) =>
    @project.sourceSets.get name

  createTask : ( args... ) =>
    @project.task args...

  task : ( name ) => @project.tasks.get(name).task
  extension : ( name ) => @project.extensions.get(name)

  doApply : =>

  register : ( opts = {} )=>
    for own k,v of opts.extensions
      @project.extensions.add k, toObj v

    for own k,v of opts.conventions
      @project.conventions.add k, toObj v, name: k

    for own k,v of opts.configurations
      @project.configurations.add k, toObj v, name: k

    for own k,v of opts.taskFactory
      TaskFactory.register k, if !v.name then v else ( x ) -> new v(x)

module.exports = Plugin