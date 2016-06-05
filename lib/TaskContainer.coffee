TaskFactory = require './TaskFactory'
TaskCollection = require './TaskCollection'
TaskInfo = require './TaskInfo'

class TaskContainer extends TaskCollection

  constructor : ->
    super()
    @taskInfo = {}

  create : ( opts, configure ) =>
    task = TaskFactory.create opts
    if @has opts.name
      throw new Error "Task already exists: #{opts.name}"
    @add task
    node = new TaskInfo task, opts
    @taskInfo[ opts.name ] = node
    node.configurator = configure task  if configure?
    task

  node : ( name ) =>
    @taskInfo[ name ]

module.exports = TaskContainer