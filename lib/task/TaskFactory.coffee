Task = require './Task'

defaultTask = ( opts ) ->
  new Task opts

class TaskFactory

  constructor : ->
    @_registry =
      default : defaultTask

  register : ( type, create ) =>
    @_registry[ type ] = create

  create : ( opts = {} ) =>
    unless opts.name
      throw new Error "The task name must be provided"

    opts.type ?= 'default'
    ctor = @_registry[ opts.type ] or @_registry.default
    task = ctor opts
    task.dependsOn opts.dependsOn if opts.dependsOn
    task.doFirst opts.action if opts.action
    task

module.exports = new TaskFactory()