Task = require './Task'
Collection = require '../util/Collection'
CopyTask = require './builtin/CopyTask'
ExecTask = require './builtin/ExecTask'

class TaskFactory extends Collection

  constructor : ->
    super()
    @register 'default', ( x ) -> new Task x
    @register 'Copy', ( x ) -> new CopyTask x
    @register 'Exec', ( x ) -> new ExecTask x

  register : ( type, create ) => @add type, create

  create : ( opts = {} ) =>
    unless opts.name
      throw new Error "The task name must be provided"

    opts.type ?= 'default'
    ctor = if @has(opts.type) then @get(opts.type) else @get('default')
    task = ctor opts
    task.dependsOn opts.dependsOn if opts.dependsOn
    task.doFirst opts.action if opts.action
    task

module.exports = new TaskFactory()