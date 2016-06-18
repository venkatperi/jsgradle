var Clock, EventEmitter, ExtensionContainer, P, Path, PluginsRegistry, Project, ScriptPhase, SeqX, TaskContainer, TaskFactory, TaskGraphExecutor, _, log, multi, prop,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

_ = require('lodash');

multi = require('heterarchy').multi;

EventEmitter = require('events').EventEmitter;

TaskFactory = require('../task/TaskFactory');

Path = require('./Path');

ScriptPhase = require('./ScriptPhase');

P = require('../util/P');

prop = require('../util/prop');

TaskContainer = require('../task/TaskContainer');

ExtensionContainer = require('../ext/ExtensionContainer');

TaskGraphExecutor = require('./TaskGraphExecutor');

PluginsRegistry = require('./PluginsRegistry');

log = require('../util/logger')('Project');

SeqX = require('../util/SeqX');

Clock = require('../util/Clock');

module.exports = Project = (function(superClass) {
  extend(Project, superClass);

  prop(Project, 'path', {
    get: function() {
      return this._path.fullPath;
    }
  });

  prop(Project, 'rootDir', {
    get: function() {
      return this._rootDir;
    }
  });

  prop(Project, 'buildDir', {
    get: function() {
      return this._buildDir;
    }
  });

  prop(Project, 'buildFile', {
    get: function() {
      return this._buildFile;
    }
  });

  prop(Project, 'childProjects', {
    get: function() {}
  });

  prop(Project, 'allProjects', {
    get: function() {}
  });

  prop(Project, 'subProjects', {
    get: function() {}
  });

  prop(Project, 'description', {
    get: function() {
      return this._description;
    },
    set: function(v) {
      return this._set('_description', v);
    }
  });

  prop(Project, 'version', {
    get: function() {
      return this._version;
    },
    set: function(v) {
      return this._set('_version', v);
    }
  });

  prop(Project, 'status', {
    get: function() {
      return this._status;
    },
    set: function(v) {
      return this._set('_status', v);
    }
  });

  function Project(arg) {
    var ref;
    ref = arg != null ? arg : {}, this.name = ref.name, this.parent = ref.parent, this.projectDir = ref.projectDir, this.script = ref.script;
    this.toString = bind(this.toString, this);
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    this.runp = bind(this.runp, this);
    this.methodMissing = bind(this.methodMissing, this);
    this.compareTo = bind(this.compareTo, this);
    this.task = bind(this.task, this);
    this.apply = bind(this.apply, this);
    this.defaultTasks = bind(this.defaultTasks, this);
    this.execute = bind(this.execute, this);
    this.configure = bind(this.configure, this);
    this.initialize = bind(this.initialize, this);
    if (this.name == null) {
      throw new Error("Project name must be defined");
    }
    log.v('ctor()', this.name);
    this.rootProject = (typeof parent !== "undefined" && parent !== null ? parent.rootProject : void 0) || this;
    if (this.description == null) {
      this.description = "project " + this.name;
    }
    if (this.version == null) {
      this.version = "0.1.0";
    }
    this.pluginsRegistry = new PluginsRegistry();
    this.tasks = new TaskContainer();
    this.extensions = new ExtensionContainer();
    this.plugins = {};
    this._prop = {};
    if (this.parent) {
      this._path = new Path(this.parent.absoluteProjectPath(name));
      this.depth = this.parent.depth + 1;
    } else {
      this.depth = 0;
      this._path = new Path([this.name], true);
    }
  }

  Project.prototype.initialize = function() {
    return log.v('initialize');
  };

  Project.prototype.configure = function() {
    var clock, tag;
    clock = new Clock();
    tag = "configuring " + this.path;
    log.v(tag);
    this.tasks.forEach((function(_this) {
      return function(t) {
        return _this.seq(function() {
          return _this.runp(t.configure);
        });
      };
    })(this));
    this.onAfterEvaluate();
    return this.seq((function(_this) {
      return function() {
        return log.v(tag, 'done', clock.pretty);
      };
    })(this));
  };

  Project.prototype.execute = function() {
    var clock, executor, nodes, t, tag;
    tag = "executing " + this.path;
    log.v(tag);
    clock = new Clock();
    executor = new TaskGraphExecutor(this.tasks);
    nodes = (function() {
      var i, len, ref, results;
      ref = this._defaultTasks;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        t = ref[i];
        results.push(this.tasks.get(t));
      }
      return results;
    }).call(this);
    executor.add(nodes);
    executor.determineExecutionPlan();
    log.i('tasks:', _.map(executor.executionQueue, function(x) {
      return x.task.name;
    }));
    executor.executionQueue.forEach((function(_this) {
      return function(t) {
        return _this.seq(t.execute);
      };
    })(this));
    return this.seq((function(_this) {
      return function() {
        return log.v(tag, 'done: ', clock.pretty);
      };
    })(this));
  };

  Project.prototype.defaultTasks = function() {
    var tasks;
    tasks = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this._defaultTasks = tasks;
  };

  Project.prototype.property = function(name, val) {
    var old;
    old = this._prop[name];
    if (arguments.length === 1) {
      return prop;
    }
    if (val !== old) {
      this[name] = val;
      this.emit('property', name, val, old);
    }
    return this;
  };

  Project.prototype.apply = function(opts) {
    var ctor, name, plugin;
    if (opts != null ? opts.plugin : void 0) {
      name = opts.plugin;
      if (!this.pluginsRegistry.has(name)) {
        throw new Error("No such plugin: " + name);
      }
      ctor = this.pluginsRegistry.get(name);
      plugin = this.plugins[name] = new ctor();
      return plugin.apply(this);
    }
  };

  Project.prototype.task = function(name, opts, f) {
    var cfg, ref, ref1, runWith;
    if (Array.isArray(name)) {
      f = opts;
      ref = name, name = ref[0], opts = ref[1];
    }
    if (f == null) {
      ref1 = [opts], f = ref1[0], opts = ref1[1];
    }
    if (opts == null) {
      opts = {};
    }
    opts.name = name;
    opts.project = this;
    opts.runWith = runWith = this.script.context.runWith;
    if (f != null) {
      cfg = function(task) {
        return function() {
          return runWith((function() {
            return f(task);
          }), task);
        };
      };
    }
    return this.tasks.create(opts, f);
  };

  Project.prototype.compareTo = function(other) {
    var diff;
    diff = this.depth - other.depth;
    if (diff !== 0) {
      return diff;
    }
    if (this.path < other.path) {
      return -1;
    }
    if (this.path > other.path) {
      return 1;
    }
    return 0;
  };

  Project.prototype.methodMissing = function() {
    var args, name;
    name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    if (!this.extensions.has(name)) {
      return;
    }
    log.v('methodMissing:', name);
    this.script.context.runWith(args[0], this.extensions.get(name));
    return true;
  };

  Project.prototype.runp = function(fn, args, ctx) {
    var err, error, list, p, ret, run;
    if (args == null) {
      args = [];
    }
    if (ctx == null) {
      ctx = [];
    }
    p = new P();
    args.push(p);
    run = this.script.context.runWith;
    try {
      list = [
        (function() {
          return fn.apply(null, args);
        })
      ];
      list = list.concat(ctx);
      list.push(p);
      ret = run.apply(this.script.context, list);
      if (!p.asyncCalled) {
        p.resolve(ret);
      }
    } catch (error) {
      err = error;
      p.reject(err);
    }
    return p.promise;
  };

  Project.prototype.onAfterEvaluate = function() {
    var clock, tag;
    clock = new Clock();
    tag = "onAfterEvaluate " + this.path;
    log.v(tag);
    this.tasks.forEach((function(_this) {
      return function(t) {
        return _this.seq(t.onAfterEvaluate);
      };
    })(this));
    return this._seq((function(_this) {
      return function() {
        return log.v(tag, 'done:', clock.pretty);
      };
    })(this));
  };

  Project.prototype._set = function(name, val) {
    var old;
    old = this[name];
    if (val !== this[name]) {
      this[name] = val;
      this.emit('change', name, val, old);
    }
    return this;
  };

  Project.prototype.toString = function() {
    return "project " + name;
  };

  return Project;

})(multi(EventEmitter, SeqX));
