_ = require 'lodash'
Multimap = require 'multimap'
{EventEmitter} = require 'events'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class TaskGraphExecutor extends EventEmitter

  constructor : ( @container ) ->
    @container.forEach ( t ) -> t.reset()
    @executionPlan = new Set()
    @executionQueue = []
    @entryTasks = []
    @filter = ( x ) -> x.enabled

  add : ( nodes ) =>
    queue = []
    sorted = Array.from nodes
    sorted = sorted.sort ( a, b ) -> a.task.compareTo b.task

    for node in sorted when node?
      if node.isMustNotRun
        requireWithDependencies node
      else if @filter node.task
        node.require()

      @entryTasks.push node
      queue.push node

    visiting = new Set()

    while (queue.length)
      node = queue[ 0 ]
      if node.dependenciesProcessed
        queue.shift()
        continue

      task = node.task
      filtered = !@filter task
      if filtered
        queue.shift()
        node.dependenciesProcessed = true
        node.doNotRequire()
        continue

      if !visiting.has node
        visiting.add node

        dependsOnTasks = node.dependsOn
        for t in dependsOnTasks
          targetNode = @container.get t
          node.addDependencySuccessor targetNode
          if !visiting.has targetNode
            queue.splice 0, 0, targetNode

        if node.isRequired
          node.dependencySuccessors.forEach ( s ) =>
            if @filter s.task
              s.require()
      else
        queue.shift()
        visiting.delete node
        node.dependenciesProcessed = true

  determineExecutionPlan : =>
    i = 0
    nodeQueue = _.map @entryTasks,
      ( x ) -> taskInfo : x, visitingSegment : i++

    visitingNodes = new Multimap()
    path = []

    while (nodeQueue.length)
      #console.log _.map nodeQueue, ( x ) -> x.taskInfo.task.name
      ti = nodeQueue[ 0 ]
      currentSegment = ti.visitingSegment
      taskNode = ti.taskInfo

      if taskNode.isIncludeInGraph or @executionPlan.has taskNode
        #console.log 'removing ' + taskNode.task.name
        nodeQueue.shift()
        continue

      alreadyVisited = visitingNodes.has taskNode
      visitingNodes.set taskNode, currentSegment

      if !alreadyVisited
        successors = Array.from(taskNode.dependencySuccessors).reverse()
        for successor in successors
          #if visitingNodes.has successor, currentSegment
          #console.log "circular? #{successor.toString()}, #{currentSegment}"
          #throw new Error 'circular dep'
          nodeQueue.splice 0, 0,
            taskInfo : successor,
            visitingSegment : currentSegment

        #console.log _.map nodeQueue, (x) -> x.taskInfo.task.name
        path.splice 0, 0, taskNode
      else
        #console.log 'removing 2 ' + taskNode.task.name
        nodeQueue.shift()
        visitingNodes.delete taskNode, currentSegment
        path.shift()
        @executionPlan.add taskNode

    @executionQueue = Array.from @executionPlan

module.exports = TaskGraphExecutor