var EventEmitter, Multimap, TaskGraphExecutor, _,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

Multimap = require('multimap');

EventEmitter = require('events').EventEmitter;

TaskGraphExecutor = (function(superClass) {
  extend(TaskGraphExecutor, superClass);

  function TaskGraphExecutor(container) {
    this.container = container;
    this.determineExecutionPlan = bind(this.determineExecutionPlan, this);
    this.add = bind(this.add, this);
    this.executionPlan = new Set();
    this.executionQueue = [];
    this.entryTasks = [];
    this.filter = function() {
      return true;
    };
  }

  TaskGraphExecutor.prototype.add = function(nodes) {
    var dependsOnTasks, filtered, j, k, l, len, len1, node, queue, results, sorted, t, targetNode, task, v, visiting;
    queue = [];
    sorted = [];
    for (k in nodes) {
      if (!hasProp.call(nodes, k)) continue;
      v = nodes[k];
      sorted.push(v);
    }
    sorted = sorted.sort(function(a, b) {
      return a.task.compareTo(b.task);
    });
    for (j = 0, len = sorted.length; j < len; j++) {
      node = sorted[j];
      if (node.isMustNotRun) {
        requireWithDependencies(node);
      } else if (this.filter(node.task)) {
        node.require();
      }
      this.entryTasks.push(node);
      queue.push(node);
    }
    visiting = new Set();
    results = [];
    while (queue.length) {
      node = queue[0];
      if (node.dependenciesProcessed) {
        queue.shift();
        continue;
      }
      task = node.task;
      filtered = !this.filter(task);
      if (filtered) {
        queue.shift();
        node.dependenciesProcessed = true;
        node.doNotRequire();
        continue;
      }
      if (!visiting.has(node)) {
        visiting.add(node);
        dependsOnTasks = node.dependsOn;
        for (l = 0, len1 = dependsOnTasks.length; l < len1; l++) {
          t = dependsOnTasks[l];
          targetNode = this.container.get(t);
          node.addDependencySuccessor(targetNode);
          if (!visiting.has(targetNode)) {
            queue.splice(0, 0, targetNode);
          }
        }
        if (node.isRequired) {
          results.push(node.dependencySuccessors.forEach((function(_this) {
            return function(s) {
              if (_this.filter(s.task)) {
                return s.require();
              }
            };
          })(this)));
        } else {
          results.push(void 0);
        }
      } else {
        queue.shift();
        visiting["delete"](node);
        results.push(node.dependenciesProcessed = true);
      }
    }
    return results;
  };

  TaskGraphExecutor.prototype.determineExecutionPlan = function() {
    var alreadyVisited, currentSegment, i, j, len, nodeQueue, path, successor, successors, taskNode, ti, visitingNodes;
    i = 0;
    nodeQueue = _.map(this.entryTasks, function(x) {
      return {
        taskInfo: x,
        visitingSegment: i++
      };
    });
    visitingNodes = new Multimap();
    path = [];
    while (nodeQueue.length) {
      ti = nodeQueue[0];
      currentSegment = ti.visitingSegment;
      taskNode = ti.taskInfo;
      if (taskNode.isIncludeInGraph || this.executionPlan.has(taskNode)) {
        nodeQueue.shift();
        continue;
      }
      alreadyVisited = visitingNodes.has(taskNode);
      visitingNodes.set(taskNode, currentSegment);
      if (!alreadyVisited) {
        successors = Array.from(taskNode.dependencySuccessors).reverse();
        for (j = 0, len = successors.length; j < len; j++) {
          successor = successors[j];
          nodeQueue.splice(0, 0, {
            taskInfo: successor,
            visitingSegment: currentSegment
          });
        }
        path.splice(0, 0, taskNode);
      } else {
        nodeQueue.shift();
        visitingNodes["delete"](taskNode, currentSegment);
        path.shift();
        this.executionPlan.add(taskNode);
      }
    }
    return this.executionQueue = Array.from(this.executionPlan);
  };

  return TaskGraphExecutor;

})(EventEmitter);

module.exports = TaskGraphExecutor;
