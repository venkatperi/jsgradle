var ClearCacheTask, Collection, CopyTask, ExecTask, RmdirTask, Task, TaskFactory, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Task = require('./Task');

Collection = require('../common/Collection');

CopyTask = require('./builtin/CopyTask');

ExecTask = require('./builtin/ExecTask');

rek = require('rekuire');

ClearCacheTask = rek('ClearCacheTask');

RmdirTask = rek('RmdirTask');

TaskFactory = (function(superClass) {
  extend(TaskFactory, superClass);

  function TaskFactory() {
    this.create = bind(this.create, this);
    this.register = bind(this.register, this);
    TaskFactory.__super__.constructor.call(this);
    this.register('default', function(x) {
      return new Task(x);
    });
    this.register('Copy', function(x) {
      return new CopyTask(x);
    });
    this.register('Exec', function(x) {
      return new ExecTask(x);
    });
    this.register('Rmdir', function(x) {
      return new RmdirTask(x);
    });
    this.register('ClearCacheTask', function(x) {
      return new ClearCacheTask(x);
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
    if (!opts.project) {
      throw new Error("Missing option: project");
    }
    if (opts.type == null) {
      opts.type = 'default';
    }
    if (!this.has(opts.type)) {
      throw new Error("Don't know how to create task with type '" + opts.type + "'");
    }
    ctor = this.get(opts.type);
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
