TaskFactory = require './TaskFactory'
Collection = require '../common/Collection'
TaskInfo = require './TaskInfo'

class TaskContainer extends Collection

  constructor : ->
    super()

  create : ( opts, configure ) =>
    task = TaskFactory.create opts
    node = new TaskInfo task, opts
    node.configurators.push configure if configure?
    @add opts.name, node
    task

  #getByName : ( name ) => @get(name).task

module.exports = TaskContainer