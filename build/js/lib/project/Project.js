var BaseObject, Clock, ConfigurationContainer, ConventionContainer, DependenciesExt, Dependency, ExtensionContainer, FileResolver, Path, PluginContainer, PluginsRegistry, Project, ProxyFactory, Q, ScriptPhase, SourceSetContainer, TaskContainer, TaskFactory, TaskGraphExecutor, Templates, _, conf, configurable, log, out, path, prop, qflow, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

path = require('path');

rek = require('rekuire');

Q = require('q');

_ = require('lodash');

BaseObject = rek('BaseObject');

Clock = rek('Clock');

ExtensionContainer = rek('lib/ext/ExtensionContainer');

FileResolver = rek('FileResolver');

out = rek('lib/util/out');

Path = require('./../common/Path');

PluginContainer = require('./../plugins/PluginContainer');

ConventionContainer = rek('ConventionContainer');

ConfigurationContainer = rek('ConfigurationContainer');

PluginsRegistry = require('./../plugins/PluginsRegistry');

prop = rek('lib/util/prop');

ProxyFactory = rek('ProxyFactory');

ScriptPhase = require('./ScriptPhase');

SourceSetContainer = rek('lib/task/SourceSetContainer');

TaskContainer = rek('lib/task/TaskContainer');

TaskFactory = rek('lib/task/TaskFactory');

TaskGraphExecutor = require('./TaskGraphExecutor');

DependenciesExt = rek('DependenciesExt');

Dependency = rek('Dependency');

conf = rek('conf');

Templates = require('../templates');

configurable = rek('configurable');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

qflow = rek('qflow');

Project = (function(superClass) {
  extend(Project, superClass);

  function Project() {
    this.toString = bind(this.toString, this);
    this.execTaskAction = bind(this.execTaskAction, this);
    this.callScriptMethod = bind(this.callScriptMethod, this);
    this.compareTo = bind(this.compareTo, this);
    this.task = bind(this.task, this);
    this.apply = bind(this.apply, this);
    this.defaultTasks = bind(this.defaultTasks, this);
    this.report = bind(this.report, this);
    this.configure = bind(this.configure, this);
    this.execute = bind(this.execute, this);
    this.afterEvaluate = bind(this.afterEvaluate, this);
    this.initialize = bind(this.initialize, this);
    this.file = bind(this.file, this);
    this.getSourceSets = bind(this.getSourceSets, this);
    this.registerProxyFactory = bind(this.registerProxyFactory, this);
    this._getErrorMessages = bind(this._getErrorMessages, this);
    this._init = bind(this._init, this);
    return Project.__super__.constructor.apply(this, arguments);
  }

  prop(Project, 'pkg', {
    get: function() {
      return this.extensions.get('pkg');
    }
  });

  prop(Project, 'originalPkg', {
    get: function() {
      return this.extensions.get('__pkg');
    }
  });

  prop(Project, 'path', {
    get: function() {
      return this._path.fullPath;
    }
  });

  prop(Project, 'continueOnError', {
    get: function() {
      return this.script.continueOnError;
    }
  });

  prop(Project, 'cacheDir', {
    get: function() {
      return this._cache.get('cacheDir', (function(_this) {
        return function() {
          return _this.fileResolver.file(conf.get('project:cache:cacheDir'));
        };
      })(this));
    }
  });

  prop(Project, 'rootDir', {
    get: function() {
      return this._rootDir;
    }
  });

  prop(Project, 'buildDir', {
    get: function() {
      return this._cache.get('buildDir', (function(_this) {
        return function() {
          return path.join(_this.projectDir, conf.get('project:build:buildDir', 'build'));
        };
      })(this));
    }
  });

  prop(Project, 'genDir', {
    get: function() {
      return this._cache.get('genDir', (function(_this) {
        return function() {
          return _this.file(conf.get('project:build:genDir', 'gen'));
        };
      })(this));
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

  prop(Project, 'failed', {
    get: function() {
      return this.tasks.some(function(x) {
        return x.task.failed;
      });
    }
  });

  prop(Project, 'taskQueueNames', {
    get: function() {
      return _.map(this.taskQueue, (function(_this) {
        return function(x) {
          if (_this.isMultiProject) {
            return x.task.path;
          } else {
            return x.task.displayName;
          }
        };
      })(this));
    }
  });

  prop(Project, 'failedTasks', {
    get: function() {
      return this.tasks.filter(function(x) {
        return x.task.failed;
      });
    }
  });

  prop(Project, 'messages', {
    get: function() {
      return _.flatten(_.map(this.failedTasks, function(x) {
        return x.messages;
      }));
    }
  });

  prop(Project, 'description', {
    get: function() {
      return this._description;
    },
    set: function(v) {
      var ref;
      this._set('_description', v);
      return (ref = this.pkg) != null ? ref.description = v : void 0;
    }
  });

  prop(Project, 'version', {
    get: function() {
      return this._version;
    },
    set: function(v) {
      var ref;
      this._set('_version', v);
      return (ref = this.pkg) != null ? ref.version = v : void 0;
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

  Project._addProperties({
    required: ['name', 'projectDir', 'script'],
    optional: ['parent'],
    exported: ['description', 'name', 'version'],
    exportedReadOnly: [],
    exportedMethods: ['apply', 'defaultTasks', 'println']
  });

  Project.prototype._init = function() {
    var i, len, p, ref, ref1, results;
    this.isMultiProject = false;
    this.rootProject = ((ref = this.parent) != null ? ref.rootProject : void 0) || this;
    this._defaultTasks = conf.get('project:build:defaultTasks', []);
    this.templates = new Templates();
    this.fileResolver = new FileResolver({
      projectDir: this.projectDir
    });
    this.pluginsRegistry = new PluginsRegistry({
      project: this
    });
    this.tasks = new TaskContainer();
    this.conventions = new ConventionContainer();
    this.configurations = new ConfigurationContainer();
    this.extensions = new ExtensionContainer();
    this.plugins = new PluginContainer;
    this.templates.on('error', (function(_this) {
      return function(err) {
        console.log(err);
        return _this.addError(err);
      };
    })(this));
    this.extensions.on('add', (function(_this) {
      return function(name, ext) {
        if (_.startsWith(name, '__')) {
          return;
        }
        return _this.registerProxyFactory(ext, name);
      };
    })(this));
    this.conventions.on('add', (function(_this) {
      return function(name, obj) {
        return obj.apply(_this);
      };
    })(this));
    this.extensions.add('dependencies', new DependenciesExt());
    this.configurations.on('add', (function(_this) {
      return function(name, cfg) {
        return _this.extensions.get('dependencies').onConfigurationAdded(name, cfg);
      };
    })(this));
    if (this.description == null) {
      this.description = "project " + this.name;
    }
    if (this.version == null) {
      this.version = conf.get('project:build:version');
    }
    if (this.parent) {
      this._path = new Path(this.parent.absoluteProjectPath(name));
      this.depth = this.parent.depth + 1;
    } else {
      this.depth = 0;
      this._path = new Path([this.name], true);
    }
    ref1 = conf.get('project:startup:plugins') || [];
    results = [];
    for (i = 0, len = ref1.length; i < len; i++) {
      p = ref1[i];
      results.push(this.apply({
        plugin: p
      }));
    }
    return results;
  };

  Project.prototype._getErrorMessages = function() {
    return _.flatten(_.map(this.failedTasks, function(x) {
      return x.messages;
    }));
  };

  Project.prototype.registerProxyFactory = function(target, name) {
    return this.script.registerFactory(name, new ProxyFactory({
      target: target,
      script: this.script
    }));
  };

  Project.prototype.println = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return (ref = out.eolThen('')).white.apply(ref, args).eol();
  };

  Project.prototype.getSourceSets = function() {
    return this.extensions.get('sourceSets');
  };

  Project.prototype.file = function(name) {
    return this.fileResolver.file(name);
  };

  Project.prototype.initialize = function() {};

  Project.prototype.afterEvaluate = function() {
    var afterSize, numTasks;
    this.emit('project:afterEvaluate:start', this);
    numTasks = this.tasks.size;
    afterSize = 0;
    return qflow.until((function(_this) {
      return function() {
        var executor, i, len, n, nodes, t, tasks;
        numTasks = _this.tasks.size;
        executor = new TaskGraphExecutor(_this.tasks);
        tasks = _this._tasksToExecute || _this._defaultTasks;
        nodes = (function() {
          var i, len, ref, results;
          ref = _.flatten(tasks);
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            t = ref[i];
            results.push(this.tasks.get(t));
          }
          return results;
        }).call(_this);
        for (i = 0, len = nodes.length; i < len; i++) {
          n = nodes[i];
          n.task.enable();
        }
        executor.add(nodes);
        _this.taskQueue = executor.determineExecutionPlan();
        return qflow.each(_this.taskQueue, function(t) {
          return t.afterEvaluate();
        }).then(function() {
          afterSize = _this.tasks.size;
          return numTasks === afterSize;
        });
      };
    })(this))["finally"]((function(_this) {
      return function() {
        return _this.emit('project:afterEvaluate:end', _this);
      };
    })(this));
  };

  Project.prototype.execute = function() {
    if (this.failed) {
      return;
    }
    this.emit('project:execute:start', this);
    return qflow.each(this.taskQueue, function(t) {
      return t.execute();
    })["finally"]((function(_this) {
      return function() {
        return _this.emit('project:execute:end', _this);
      };
    })(this));
  };

  Project.prototype.configure = function() {
    this.emit('project:configure:start', this);
    return this.tasks.forEachp(function(t) {
      return t.configure();
    })["finally"]((function(_this) {
      return function() {
        return _this.emit('project:configure:end', _this);
      };
    })(this));
  };

  Project.prototype.report = function() {
    var errors, ex, i, len, msgs, num, ref, ref1, results, t;
    errors = [];
    if ((ref = this.taskQueue) != null) {
      ref.forEach((function(_this) {
        return function(t) {
          var ref1;
          if ((ref1 = t.errors) != null ? ref1.length : void 0) {
            return errors.push({
              name: t.name,
              errors: t.errors
            });
          }
        };
      })(this));
    }
    out.eolThen('').eol();
    if (!this.failed) {
      return out.white('BUILD SUCCESSFUL').eol();
    } else {
      msgs = Array.from(this.messages);
      num = msgs.length;
      ex = 'error';
      if (msgs.length > 1) {
        ex += 's';
      }
      out.red("FAILURE: Build failed with " + num + " " + ex + ". See task for details.").eol();
      ref1 = this.failedTasks;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        t = ref1[i];
        results.push(out('> ' + t.task.displayName).eol());
      }
      return results;
    }
  };

  Project.prototype.defaultTasks = function() {
    var i, len, results, t, tasks;
    tasks = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    results = [];
    for (i = 0, len = tasks.length; i < len; i++) {
      t = tasks[i];
      if (t != null) {
        results.push(this._defaultTasks.push(t));
      }
    }
    return results;
  };

  Project.prototype.apply = function(opts) {
    var ctor, name, plugin;
    if (Array.isArray(opts)) {
      opts = opts[0];
    }
    if (opts != null ? opts.plugin : void 0) {
      name = opts.plugin;
      if (this.plugins[name] != null) {
        return;
      }
      if (!this.pluginsRegistry.has(name)) {
        throw new Error("No such plugin: " + name);
      }
      ctor = this.pluginsRegistry.get(name);
      plugin = this.plugins[name] = new ctor({
        name: name
      });
      plugin.apply(this);
      return void 0;
    }
  };

  Project.prototype.task = function(name, opts, f) {
    var task;
    if (opts == null) {
      opts = {};
    }
    opts.name = name;
    opts.project = this;
    task = this.tasks.create(opts);
    this.script.listenTo(task);
    if (f != null) {
      f(task);
    }
    return null;
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

  Project.prototype.callScriptMethod = function() {
    var args, delegate, fn, ref;
    delegate = arguments[0], fn = arguments[1], args = 3 <= arguments.length ? slice.call(arguments, 2) : [];
    return (ref = this.script).callScriptMethod.apply(ref, [delegate, fn].concat(slice.call(args)));
  };

  Project.prototype.execTaskAction = function(task, action) {
    var defer, err, error;
    defer = Q.defer();
    try {
      if (action.isSandbox) {
        defer.resolve(this.callScriptMethod(task, action.f));
      } else {
        defer.resolve(action.doExec());
      }
    } catch (error) {
      err = error;
      defer.reject(err);
    }
    return defer.promise;
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

})(BaseObject);

module.exports = Project;
