var Collection, TaskContainer, TaskFactory, TaskInfo,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

TaskFactory = require('./TaskFactory');

Collection = require('../common/Collection');

TaskInfo = require('./TaskInfo');

TaskContainer = (function(superClass) {
  extend(TaskContainer, superClass);

  function TaskContainer() {
    this.create = bind(this.create, this);
    TaskContainer.__super__.constructor.call(this);
  }

  TaskContainer.prototype.create = function(opts, configure) {
    var node, task;
    task = TaskFactory.create(opts);
    node = new TaskInfo(task, opts);
    if (configure != null) {
      node.configurators.push(configure);
    }
    this.add(opts.name, node);
    return task;
  };

  return TaskContainer;

})(Collection);

module.exports = TaskContainer;
