var ExecAction, ExecTask, Task, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

rek = require('rekuire');

Task = require('../Task');

ExecAction = require('./ExecAction');

ExecTask = (function(superClass) {
  extend(ExecTask, superClass);

  function ExecTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    this.workingDir = bind(this.workingDir, this);
    this.ignoreExitValue = bind(this.ignoreExitValue, this);
    this.environment = bind(this.environment, this);
    this.executable = bind(this.executable, this);
    this.commandLine = bind(this.commandLine, this);
    this.args = bind(this.args, this);
    return ExecTask.__super__.constructor.apply(this, arguments);
  }

  ExecTask._addProperties({
    exportedMethods: ['args', 'commandLine', 'executable', 'environment', 'ignoreExitValue', 'workingDir']
  });

  ExecTask.prototype.args = function() {
    var arg;
    arg = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this._args = this._args.concat(arg);
  };

  ExecTask.prototype.commandLine = function(line) {
    if (typeof line === 'string') {
      this._args = line.split(' ');
    } else if (Array.isArray(line)) {
      this._args = line;
    }
    return this._executable = this._args.shift();
  };

  ExecTask.prototype.executable = function(name) {
    return this._executable = name;
  };

  ExecTask.prototype.environment = function(env) {
    var k, results, v;
    if (this._env == null) {
      this._env = {};
    }
    results = [];
    for (k in env) {
      if (!hasProp.call(env, k)) continue;
      v = env[k];
      results.push(this._env[k] = v);
    }
    return results;
  };

  ExecTask.prototype.ignoreExitValue = function(val) {
    return this._ignoreExitValue = val;
  };

  ExecTask.prototype.workingDir = function(dir) {
    return this._workingDir = dir;
  };

  ExecTask.prototype.onAfterEvaluate = function() {
    if (this._executable == null) {
      throw new Error("No executable specified");
    }
    return this.doFirst(new ExecAction({
      spec: this,
      task: this
    }));
  };

  return ExecTask;

})(Task);

module.exports = ExecTask;
