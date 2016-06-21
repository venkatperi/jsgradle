Task = require './Task'
Collection = require '../common/Collection'
CopyTask = require './builtin/CopyTask'
ExecTask = require './builtin/ExecTask'
rek = require 'rekuire'
ClearCacheTask = rek 'ClearCacheTask'
RmdirTask = rek 'RmdirTask'

class TaskFactory extends Collection

  constructor : ->
    super()
    @register 'default', ( x ) -> new Task x
    @register 'Copy', ( x ) -> new CopyTask x
    @register 'Exec', ( x ) -> new ExecTask x
    @register 'Rmdir', ( x ) -> new RmdirTask x
    @register 'ClearCacheTask', ( x ) -> new ClearCacheTask x

  register : ( type, create ) => @add type, create

  create : ( opts = {} ) =>
    throw new Error "The task name must be provided" unless opts.name
    throw new Error "Missing option: project" unless opts.project

    opts.type ?= 'default'
    unless @has opts.type
      throw new Error "Don't know how to create task with type '#{opts.type}'"
    ctor = @get(opts.type)
    task = ctor opts
    task.dependsOn opts.dependsOn if opts.dependsOn
    task.doFirst opts.action if opts.action
    task

module.exports = new TaskFactory()