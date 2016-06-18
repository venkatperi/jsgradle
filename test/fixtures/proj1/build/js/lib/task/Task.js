var Action, Path, Task, os, p,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  slice = [].slice;

os = require('os');

p = require('./../util/prop');

Path = require('./../project/Path');

Action = require('./Action');

Task = (function() {
  p(Task, 'path', {
    get: function() {
      return this._path.fullPath;
    }
  });

  p(Task, 'temporaryDir', {
    get: function() {
      return os.tmpdir();
    }
  });

  p(Task, 'description', {
    get: function() {
      return this._description;
    },
    set: function(v) {
      return this._set('_description', v);
    }
  });

  p(Task, 'enabled', {
    get: function() {
      return this._enabled;
    },
    set: function(v) {
      return this._set('_enabled', v);
    }
  });

  p(Task, 'didWork', {
    get: function() {
      return this._didWork;
    },
    set: function(v) {
      return this._set('_didWork', v);
    }
  });

  function Task(arg) {
    this.name = arg.name, this.project = arg.project, this.description = arg.description, this.type = arg.type, this.runWith = arg.runWith;
    this.toString = bind(this.toString, this);
    this.doConfigure = bind(this.doConfigure, this);
    this.compareTo = bind(this.compareTo, this);
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    this.onlyIf = bind(this.onlyIf, this);
    this.configure = bind(this.configure, this);
    this.doLastSync = bind(this.doLastSync, this);
    this.doLast = bind(this.doLast, this);
    this.doFirstSync = bind(this.doFirstSync, this);
    this.doFirst = bind(this.doFirst, this);
    this.dependsOn = bind(this.dependsOn, this);
    this._dependencies = [];
    this.actions = [];
    this._onlyIfSpec = [];
    this._path = new Path(this.project._path.absolutePath(this.name));
  }

  Task.prototype.dependsOn = function() {
    var paths;
    paths = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    this._dependencies.push(paths.length === 1 ? paths[0] : paths);
    return this;
  };

  Task.prototype.doFirst = function(action) {
    if (action == null) {
      throw new Error("Action must not be null");
    }
    this.actions.splice(0, 0, new Action(action));
    return this;
  };

  Task.prototype.doFirstSync = function(action) {
    if (action == null) {
      throw new Error("Action must not be null");
    }
    this.actions.splice(0, 0, new Action(action, false));
    return this;
  };

  Task.prototype.doLast = function(action) {
    if (action == null) {
      throw new Error("Action must not be null");
    }
    this.actions.push(new Action(action));
    return this;
  };

  Task.prototype.doLastSync = function(action) {
    if (action == null) {
      throw new Error("Action must not be null");
    }
    this.actions.push(new Action(action, false));
    return this;
  };

  Task.prototype.configure = function(p) {};

  Task.prototype.onlyIf = function(fn) {
    return this._onlyIfSpec.push(fn);
  };

  Task.prototype.onAfterEvaluate = function() {};

  Task.prototype.compareTo = function(other) {
    var c;
    c = this.project.compareTo(other.project);
    if (c !== 0) {
      return c;
    }
    if (this.path < other.path) {
      return -1;
    }
    if (this.path > other.path) {
      return 1;
    }
    return 0;
  };

  Task.prototype._set = function(name, val) {
    var old;
    old = this[name];
    if (val !== this[name]) {
      this[name] = val;
      this.emit('change', name, val, old);
    }
    return this;
  };

  Task.prototype.doConfigure = function() {};

  Task.prototype.toString = function() {
    return "task " + this.name;
  };

  return Task;

})();

module.exports = Task;
