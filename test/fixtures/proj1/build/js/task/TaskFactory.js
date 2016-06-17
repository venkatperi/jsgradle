var Collection, CopyTask, Task, TaskFactory, defaultTask,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Task = require('./Task');

Collection = require('../util/Collection');

CopyTask = require('./builtin/CopyTask');

defaultTask = function(opts) {
  return new Task(opts);
};

TaskFactory = (function(superClass) {
  extend(TaskFactory, superClass);

  function TaskFactory() {
    this.create = bind(this.create, this);
    this.register = bind(this.register, this);
    TaskFactory.__super__.constructor.call(this);
    this.register('default', defaultTask);
    this.register('Copy', function(x) {
      return new CopyTask(x);
    });
  }

  TaskFactory.prototype.register = function(type, create) {
    return this.add(type, create);
  };

  TaskFactory.prototype.create = function(opts) {
    var ctor, task;
    if (opts == null) {
      opts = {};
    }
    if (!opts.name) {
      throw new Error("The task name must be provided");
    }
    if (opts.type == null) {
      opts.type = 'default';
    }
    ctor = this.get(opts.type) || this.get('default');
    task = ctor(opts);
    if (opts.dependsOn) {
      task.dependsOn(opts.dependsOn);
    }
    if (opts.action) {
      task.doFirst(opts.action);
    }
    return task;
  };

  return TaskFactory;

})(Collection);

module.exports = new TaskFactory();
