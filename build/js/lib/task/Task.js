var Action, BaseObject, Path, Q, Task, TaskStats, _, os, p, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

rek = require('rekuire');

_ = require('lodash');

Q = require('q');

os = require('os');

p = rek('lib/util/prop');

Path = require('../common/Path');

BaseObject = rek('BaseObject');

Action = rek('Action');

TaskStats = require('./TaskStats');

Task = (function(superClass) {
  extend(Task, superClass);

  function Task() {
    this._getErrorMessages = bind(this._getErrorMessages, this);
    this._checkFailed = bind(this._checkFailed, this);
    this._didWork = bind(this._didWork, this);
    this._onAfterEvaluate = bind(this._onAfterEvaluate, this);
    this._doAfterEvaluate = bind(this._doAfterEvaluate, this);
    this._checkDidWork = bind(this._checkDidWork, this);
    this.summary = bind(this.summary, this);
    this.toString = bind(this.toString, this);
    this.compareTo = bind(this.compareTo, this);
    this.doLast = bind(this.doLast, this);
    this.doFirst = bind(this.doFirst, this);
    this.dependsOn = bind(this.dependsOn, this);
    this.enable = bind(this.enable, this);
    this.configure = bind(this.configure, this);
    this.outputName = bind(this.outputName, this);
    this._init = bind(this._init, this);
    return Task.__super__.constructor.apply(this, arguments);
  }

  Task._addProperties({
    required: ['name', 'project', 'type'],
    optional: ['description', 'options'],
    exported: ['description', 'didWork', 'enabled'],
    exportedReadOnly: ['name', 'actions', 'dependencies', 'temporaryDir'],
    exportedMethods: ['doFirst', 'doLast']
  });

  p(Task, 'path', {
    get: function() {
      return this._path.fullPath;
    }
  });

  p(Task, 'displayName', {
    get: function() {
      return ":" + this.name;
    }
  });

  p(Task, 'capitalizedName', {
    get: function() {
      return this._cache.get('capitalizedName', (function(_this) {
        return function() {
          return _.upperFirst(_this.name);
        };
      })(this));
    }
  });

  p(Task, 'temporaryDir', {
    get: function() {
      return os.tmpdir();
    }
  });

  p(Task, 'didWork', {
    get: function() {
      return this._didWork();
    },
    set: function(v) {
      return this._taskDidWork = v;
    }
  });

  p(Task, 'failedActions', {
    get: function() {
      return this._cache.get('failedActions', (function(_this) {
        return function() {
          return _.filter(_this.actions, function(x) {
            return x.failed;
          });
        };
      })(this));
    }
  });

  Task.prototype._init = function(opts) {
    this.stats = new TaskStats();
    if (this.description == null) {
      this.description = "task " + this.name;
    }
    this.enabled = true;
    this.dependencies = [];
    this.actions = [];
    this._path = new Path(this.project._path.absolutePath(this.name));
    this.on('error', (function(_this) {
      return function() {
        return _this._cache["delete"]('failedActions');
      };
    })(this));
    return Task.__super__._init.call(this, opts);
  };

  Task.prototype.outputName = function(input) {};

  Task.prototype.configure = function() {};

  Task.prototype.enable = function(recursive) {
    var d, i, len, ref, results;
    if (recursive == null) {
      recursive = false;
    }
    this.enabled = true;
    if (recursive) {
      ref = this.dependencies;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        d = ref[i];
        results.push(this.project.tasks.get(d).task.enable(recursive));
      }
      return results;
    }
  };

  Task.prototype.dependsOn = function() {
    var paths;
    paths = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return this.dependencies = _.flatten(_.concat(this.dependencies, paths));
  };

  Task.prototype.doFirst = function(action) {
    if (Array.isArray(action)) {
      action = action[0];
    }
    if (!(action instanceof Action)) {
      action = new Action({
        f: action,
        task: this
      });
    }
    return this.actions.splice(0, 0, action);
  };

  Task.prototype.doLast = function(action) {
    if (Array.isArray(action)) {
      action = action[0];
    }
    if (action == null) {
      throw new Error("Action must not be null");
    }
    if (!(action instanceof Action)) {
      action = new Action({
        f: action,
        task: this
      });
    }
    return this.actions.push(action);
  };

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

  Task.prototype.toString = function() {
    return "task " + this.name;
  };

  Task.prototype.summary = function() {
    var msg, str;
    if (this.failed) {
      if (this.messages) {
        msg = Array.from(this.messages);
      } else {
        msg = [];
      }
      msg.unshift('FAILED');
      return msg.join('\n');
    } else {
      if (!this._checkDidWork()) {
        return 'UP-TO-DATE';
      }
      str = [];
      if (this.stats.hasFiles) {
        str.push(this.stats.notCached + "(" + this.stats.files + ") file(s)");
      }
      str.push('OK');
      return str.join(' ');
    }
  };

  Task.prototype._checkDidWork = function() {
    var d, i, len, ref;
    if (this.didWork) {
      return true;
    }
    ref = this.dependencies;
    for (i = 0, len = ref.length; i < len; i++) {
      d = ref[i];
      if (this.project.tasks.get(d).task._checkDidWork()) {
        return true;
      }
    }
  };

  Task.prototype._doAfterEvaluate = function() {
    this.emit('task:afterEvaluate:start', this);
    return this.configured = Q["try"](this._onAfterEvaluate).fail((function(_this) {
      return function(err) {
        return _this.addError(err);
      };
    })(this))["finally"]((function(_this) {
      return function() {
        return _this.emit('task:afterEvaluate:end', _this);
      };
    })(this));
  };

  Task.prototype._onAfterEvaluate = function() {};

  Task.prototype._didWork = function() {
    if (this._taskDidWork) {
      return true;
    }
    if (this.stats.didWork) {
      return true;
    }
    return false;
  };

  Task.prototype._checkFailed = function() {
    return Task.__super__._checkFailed.call(this) || _.some(this.actions, function(x) {
      return x.failed;
    });
  };

  Task.prototype._getErrorMessages = function() {
    var list;
    list = _.map(this.failedActions, function(x) {
      return x.messages;
    });
    list = _.concat(list, _.map(this.errors, function(x) {
      return x.message;
    }));
    return _.map(_.flatten(list), function(x) {
      return '> ' + x;
    });
  };

  return Task;

})(BaseObject);

module.exports = Task;
