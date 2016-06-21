var Clock, ConsoleReporter, CopySpecFactory, FactoryBuilderSupport, HrTime, OptionsFactory, Project, ProjectFactory, Q, Script, TaskBuilderFactory, _, conf, defaultFactories, fs, isFile, out, path, prop, readFile, ref, rek, time, walkup,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

Q = require('q');

path = require('path');

fs = require('fs');

FactoryBuilderSupport = require('coffee-dsl').FactoryBuilderSupport;

walkup = require('node-walkup');

rek = require('rekuire');

Project = rek('Project');

out = rek('lib/util/out');

TaskBuilderFactory = rek('lib/factory/TaskBuilderFactory');

ProjectFactory = rek('lib/factory/ProjectFactory');

CopySpecFactory = rek('lib/factory/CopySpecFactory');

OptionsFactory = rek('lib/factory/OptionsFactory');

ref = rek('fileOps'), isFile = ref.isFile, readFile = ref.readFile;

time = rek('time');

HrTime = rek('HrTime');

Clock = rek('Clock');

conf = rek('conf');

ConsoleReporter = rek('ConsoleReporter');

prop = rek('prop');

defaultFactories = {
  project: ProjectFactory,
  task: TaskBuilderFactory,
  from: CopySpecFactory,
  into: CopySpecFactory,
  filter: CopySpecFactory,
  options: OptionsFactory
};

Script = (function(superClass) {
  extend(Script, superClass);

  prop(Script, 'failed', {
    get: function() {
      return this.errors.length || this.project.failed;
    }
  });

  prop(Script, 'messages', {
    get: function() {
      var list, ref1;
      list = _.map(this.errors, function(x) {
        return '> ' + x.message;
      });
      list = _.concat(list, (ref1 = this.project) != null ? ref1.messages : void 0);
      return list.join('\n');
    }
  });

  function Script(opts) {
    if (opts == null) {
      opts = {};
    }
    this._registerFactories = bind(this._registerFactories, this);
    this._createProjectClosure = bind(this._createProjectClosure, this);
    this._loadScript = bind(this._loadScript, this);
    this._configure = bind(this._configure, this);
    this.report = bind(this.report, this);
    this.execute = bind(this.execute, this);
    this.afterEvaluate = bind(this.afterEvaluate, this);
    this.configure = bind(this.configure, this);
    this.initialize = bind(this.initialize, this);
    this.listenTo = bind(this.listenTo, this);
    this.build = bind(this.build, this);
    this.totalTime = new Clock();
    this.errors = [];
    this.reporters = [new ConsoleReporter()];
    this.listenTo(this);
    Script.__super__.constructor.call(this, opts);
    this.buildDir = opts.buildDir || conf.get('script:build:dir');
    this.continueOnError = opts.continueOnError || conf.get('project:build:continueOnError');
    this.tasks = opts.tasks;
    this._registerFactories();
    if (this.mode == null) {
      this.mode = 'debug';
    }
    this.on('error', (function(_this) {
      return function(err) {
        if (_this.mode === 'debug') {
          return console.log(err.stack);
        }
      };
    })(this));
  }

  Script.prototype.build = function(stage) {
    if (stage == null) {
      stage = 'execute';
    }
    return this.initialize().then((function(_this) {
      return function() {
        return _this.configure().then(function() {
          if (stage === _this.stage) {
            return;
          }
          if (_this.failed) {
            return;
          }
          return _this.afterEvaluate();
        }).then(function() {
          if (stage === _this.stage) {
            return;
          }
          if (_this.failed) {
            return;
          }
          return _this.execute();
        }).fail(function(err) {
          console.log(err);
          return _this.errors.push(err);
        });
      };
    })(this)).then((function(_this) {
      return function() {
        return _this.report();
      };
    })(this));
  };

  Script.prototype.listenTo = function(obj) {
    return this.reporters.forEach(function(r) {
      return r.listenTo(obj);
    });
  };

  Script.prototype.initialize = function() {
    this.stage = 'initialize';
    this.emit('script:initialize:start', this);
    return this._loadScript()["finally"]((function(_this) {
      return function() {
        return _this.emit('script:initialize:end', _this, _this.totalTime.pretty);
      };
    })(this));
  };

  Script.prototype.configure = function() {
    var clock;
    this.stage = 'configure';
    clock = new Clock();
    this.emit('script:configure:start', this);
    return this._configure()["finally"]((function(_this) {
      return function() {
        return _this.emit('script:configure:end', _this, clock.pretty);
      };
    })(this));
  };

  Script.prototype.afterEvaluate = function() {
    var clock;
    this.stage = 'afterEvaluate';
    clock = new Clock();
    this.emit('script:afterEvaluate:start', this);
    return this.project.afterEvaluate()["finally"]((function(_this) {
      return function() {
        return _this.emit('script:afterEvaluate:end', _this, clock.pretty);
      };
    })(this));
  };

  Script.prototype.execute = function() {
    this.stage = 'execute';
    this.emit('script:execute:start', this);
    return this.project.execute()["finally"]((function(_this) {
      return function() {
        return _this.emit('script:execute:end', _this, _this.totalTime.pretty);
      };
    })(this));
  };

  Script.prototype.report = function() {
    if (this.failed) {
      if (this.errors.length) {
        out.eolThen().eol().red('FAILURE: The following error(s) occurred:').eol();
        out.grey(this.messages).eol();
      } else {
        this.project.report();
      }
    } else {
      this.project.report();
    }
    return out.eolThen('').eol().white("Total time: " + this.totalTime.pretty).eol();
  };

  Script.prototype._configure = function() {
    return Q["try"]((function(_this) {
      return function() {
        var ref1;
        _this.evaluate(_this.contents, {
          coffee: true
        });
        if ((ref1 = _this.tasks) != null ? ref1.length : void 0) {
          _this.project._tasksToExecute = _this.tasks;
        }
        return _this.project.configure();
      };
    })(this)).fail((function(_this) {
      return function(err) {
        console.log(err);
        return _this.errors.push(err);
      };
    })(this));
  };

  Script.prototype._loadScript = function() {
    var enc, fileName;
    fileName = conf.get('script:build:file');
    enc = conf.get('script:build:enc');
    return walkup(fileName, {
      cwd: this.buildDir
    }).then((function(_this) {
      return function(v) {
        if (!v.length) {
          throw new Error("Didn't find build file (" + fileName + ")");
        }
        _this.scriptFile = path.join(v[0].dir, v[0].files[0]);
        return isFile(_this.scriptFile);
      };
    })(this)).then((function(_this) {
      return function(isAFile) {
        if (!isAFile) {
          throw new Error("Not a file: " + _this.scriptFile);
        }
        return readFile(_this.scriptFile, enc);
      };
    })(this)).then((function(_this) {
      return function(contents) {
        return _this._createProjectClosure(contents);
      };
    })(this));
  };

  Script.prototype._createProjectClosure = function(contents) {
    var l, lines, name, parts, projectDir;
    parts = path.parse(this.scriptFile);
    projectDir = parts.dir;
    name = path.basename(projectDir);
    lines = contents.split('\n');
    lines = (function() {
      var i, len, results;
      results = [];
      for (i = 0, len = lines.length; i < len; i++) {
        l = lines[i];
        results.push('  ' + l);
      }
      return results;
    })();
    lines.splice(0, 0, "project '" + name + "', projectDir: '" + projectDir + "', ->");
    contents = lines.join('\n');
    return this.contents = contents;
  };

  Script.prototype._registerFactories = function() {
    var k, results, v;
    results = [];
    for (k in defaultFactories) {
      if (!hasProp.call(defaultFactories, k)) continue;
      v = defaultFactories[k];
      results.push(this.registerFactory(k, new v({
        script: this
      })));
    }
    return results;
  };

  return Script;

})(FactoryBuilderSupport);

module.exports = Script;
