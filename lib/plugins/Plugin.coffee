_ = require 'lodash'

toObj = ( x ) ->
  if _.isFunction(x) then new x() else x

class GreetingPlugin
  constructor : ->

  apply : ( project ) =>
    return if @configured
    @configured = true
    @project = project
    @doApply()

  applyPlugin : ( name ) =>
    @project.apply plugin : name

  createTask : ( args... ) =>
    @project.task args...

  task : ( name ) => @project.tasks.get(name).task
  extension : ( name ) => @project.extensions.get(name)

  doApply : =>

  register : ( opts = {} )=>
    for own k,v of opts.extensions
      @project.extensions.add k, toObj v

    for own k,v of opts.conventions
      @project.conventions.add k, toObj v

    for own k,v of opts.taskFactory
      TaskFactory.register name, ( x ) -> new v(x)

module.exports = GreetingPlugin