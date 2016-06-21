var Clock, EventEmitter, STATE, TaskInfo, assert, prop, qflow, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

assert = require('assert');

prop = require('./../util/prop');

EventEmitter = require('events').EventEmitter;

Clock = require('../util/Clock');

rek = require('rekuire');

qflow = rek('qflow');

STATE = {
  Unknown: 'Unknown',
  NotRequired: 'NotRequired',
  ShouldRun: 'ShouldRun',
  MustRun: 'MustRun',
  MustNotRun: 'MustNotRun',
  Executing: 'Executing',
  Executed: 'Executed',
  Skipped: 'Skipped'
};

TaskInfo = (function(superClass) {
  extend(TaskInfo, superClass);

  prop(TaskInfo, 'name', {
    get: function() {
      return this.task.name;
    }
  });

  prop(TaskInfo, 'displayName', {
    get: function() {
      return this.task.displayName;
    }
  });

  prop(TaskInfo, 'dependsOn', {
    get: function() {
      return this.task.dependencies;
    }
  });

  prop(TaskInfo, 'isRequired', {
    get: function() {
      return this.state === STATE.ShouldRun;
    }
  });

  prop(TaskInfo, 'isMustNotRun', {
    get: function() {
      return this.state === STATE.MustNotRun;
    }
  });

  prop(TaskInfo, 'isIncludeInGraph', {
    get: function() {
      var ref;
      return (ref = this.state) === STATE.NotRequired || ref === STATE.Unknown;
    }
  });

  prop(TaskInfo, 'isReady', {
    get: function() {
      var ref;
      return (ref = this.state) === STATE.ShouldRun || ref === STATE.MustRun;
    }
  });

  prop(TaskInfo, 'isInKnownState', {
    get: function() {
      return this.state !== STATE.Unknown;
    }
  });

  prop(TaskInfo, 'isComplete', {
    get: function() {
      var ref;
      return (ref = this.state) === STATE.Executed || ref === STATE.Skipped || ref === STATE.Unknown || ref === STATE.NotRequired || ref === STATE.MustNotRun;
    }
  });

  prop(TaskInfo, 'isSuccessful', {
    get: function() {
      var ref;
      return ((ref = this.state) === STATE.ShouldRun || ref === STATE.MustRun) || (state === STATE.Executed && !!isFailed);
    }
  });

  prop(TaskInfo, 'isFailed', {
    get: function() {
      return (this.taskFailure != null) || (this._executionFailure != null);
    }
  });

  prop(TaskInfo, 'taskFailure', {
    get: function() {
      return this.task.state.failure;
    }
  });

  function TaskInfo(task1, opts) {
    this.task = task1;
    this.toString = bind(this.toString, this);
    this.removeShouldRunAfterSuccessor = bind(this.removeShouldRunAfterSuccessor, this);
    this.addShouldSuccessor = bind(this.addShouldSuccessor, this);
    this.addFinalizer = bind(this.addFinalizer, this);
    this.addMustSuccessor = bind(this.addMustSuccessor, this);
    this.addDependencySuccessor = bind(this.addDependencySuccessor, this);
    this.allDependenciesSuccessful = bind(this.allDependenciesSuccessful, this);
    this.allDependenciesComplete = bind(this.allDependenciesComplete, this);
    this.executionFailure = bind(this.executionFailure, this);
    this.enforceRun = bind(this.enforceRun, this);
    this.mustNotRun = bind(this.mustNotRun, this);
    this.doNotRequire = bind(this.doNotRequire, this);
    this.require = bind(this.require, this);
    this.skipExecution = bind(this.skipExecution, this);
    this.finishExecution = bind(this.finishExecution, this);
    this.startExecution = bind(this.startExecution, this);
    this.execute = bind(this.execute, this);
    this.afterEvaluate = bind(this.afterEvaluate, this);
    this.configure = bind(this.configure, this);
    this.reset = bind(this.reset, this);
    this.reset();
  }

  TaskInfo.prototype.reset = function() {
    this.state = STATE.Unknown;
    this.configurators = [];
    this.dependencyPredecessors = new Set();
    this.dependencySuccessors = new Set();
    this.mustSuccessors = new Set();
    this.shouldSuccessors = new Set();
    this.finalizers = new Set();
    this.dependenciesProcessed = false;
    return this.hasErrors = 0;
  };

  TaskInfo.prototype.configure = function() {
    return this.task.configure();
  };

  TaskInfo.prototype.afterEvaluate = function() {
    if (this.evaluated) {
      return;
    }
    this.evaluated = true;
    this.task.emit('task:afterEvaluate:start', this.task);
    return this.task._doAfterEvaluate()["finally"]((function(_this) {
      return function() {
        return _this.task.emit('task:afterEvaluate:end', _this.task);
      };
    })(this));
  };

  TaskInfo.prototype.execute = function() {
    var clock, project, task;
    this.task.emit('task:execute:start', this.task);
    task = this.task;
    project = task.project;
    clock = new Clock();
    return qflow.each(task.actions, function(a) {
      return project.execTaskAction(task, a);
    })["finally"]((function(_this) {
      return function() {
        return _this.task.emit('task:execute:end', _this.task, clock.pretty);
      };
    })(this));
  };

  TaskInfo.prototype.startExecution = function() {
    assert(this.isReady);
    return this.state = STATE.Executing;
  };

  TaskInfo.prototype.finishExecution = function() {
    assert(this.state === STATE.Executing);
    return this.state = STATE.Executed;
  };

  TaskInfo.prototype.skipExecution = function() {
    assert(this.state === STATE.ShouldRun);
    return this.state = STATE.Skipped;
  };

  TaskInfo.prototype.require = function() {
    return this.state = STATE.ShouldRun;
  };

  TaskInfo.prototype.doNotRequire = function() {
    return this.state = STATE.NotRequired;
  };

  TaskInfo.prototype.mustNotRun = function() {
    return this.state = STATE.MustNotRun;
  };

  TaskInfo.prototype.enforceRun = function() {
    var ref;
    assert((ref = this.state) === STATE.ShouldRun || ref === STATE.MustNotRun || ref === STATE.MustRun);
    return this.state = STATE.MustRun;
  };

  TaskInfo.prototype.executionFailure = function(f) {
    if (arguments.length === 0) {
      return this._executionFailure;
    }
    this._executionFailure = f;
    return this.state = STATE.Executing;
  };

  TaskInfo.prototype.allDependenciesComplete = function() {
    var i, j, len, ref, s, v;
    ref = [this.mustSuccessors, this.dependencySuccessors];
    for (j = 0, len = ref.length; j < len; j++) {
      s = ref[j];
      i = s.values();
      while ((v = i.next(), !v.done)) {
        if (!v.value.isComplete) {
          return false;
        }
      }
    }
    return true;
  };

  TaskInfo.prototype.allDependenciesSuccessful = function() {
    var i, v;
    i = this.dependencySuccessors.values();
    while ((v = i.next(), !v.done)) {
      if (!v.value.isSuccessful) {
        return false;
      }
    }
    return true;
  };

  TaskInfo.prototype.addDependencySuccessor = function(to) {
    this.dependencySuccessors.add(to);
    return to.dependencyPredecessors.add(this);
  };

  TaskInfo.prototype.addMustSuccessor = function(n) {
    return this.mustSuccessors.add(n);
  };

  TaskInfo.prototype.addFinalizer = function(n) {
    return this.finalizers.add(n);
  };

  TaskInfo.prototype.addShouldSuccessor = function(n) {
    return this.shouldSuccessors.add(n);
  };

  TaskInfo.prototype.removeShouldRunAfterSuccessor = function(n) {
    return this.shouldSuccessors["delete"](n);
  };

  TaskInfo.prototype.toString = function() {
    return "TaskInfo(" + (this.task.toString()) + ")";
  };

  return TaskInfo;

})(EventEmitter);

module.exports = TaskInfo;
