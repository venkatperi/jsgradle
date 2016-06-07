Task = require './Task'
Collection = require '../util/Collection'
CopyTask = require './builtin/CopyTask'

defaultTask = ( opts ) ->
  new Task opts

class TaskFactory extends Collection

  constructor : ->
    super()
    @register 'default', defaultTask
    @register 'Copy', ( x ) -> new CopyTask x


  register : ( type, create ) => @add type, create

  create : ( opts = {} ) =>
    unless opts.name
      throw new Error "The task name must be provided"

    opts.type ?= 'default'
    ctor = @get(opts.type) or @get('default')
    task = ctor opts
    task.dependsOn opts.dependsOn if opts.dependsOn
    task.doFirst opts.action if opts.action
    task

module.exports = new TaskFactory()