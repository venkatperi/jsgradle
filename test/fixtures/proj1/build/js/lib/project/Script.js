var CoffeeDsl, Phase, Project, Q, Script, SeqX, fs, log, multi, path, readFile, walkup,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

Q = require('q');

path = require('path');

fs = require('fs');

CoffeeDsl = require('coffee-dsl');

Phase = require('./ScriptPhase');

Project = require('./Project');

log = require('../util/logger')('Script');

walkup = require('node-walkup');

SeqX = require('../util/SeqX');

multi = require('heterarchy').multi;

readFile = Q.denodeify(fs.readFile);

Script = (function(superClass) {
  extend(Script, superClass);

  function Script(arg) {
    this.scriptFile = (arg != null ? arg : {}).scriptFile;
    this._execute = bind(this._execute, this);
    this._configure = bind(this._configure, this);
    this._createProject = bind(this._createProject, this);
    this._initialize = bind(this._initialize, this);
    this._loadScript = bind(this._loadScript, this);
    this.execute = bind(this.execute, this);
    this.configure = bind(this.configure, this);
    this.initialize = bind(this.initialize, this);
    this.methodMissing = bind(this.methodMissing, this);
    if (!this.scriptFile) {
      throw new Error("Missing option: scriptFile");
    }
    Script.__super__.constructor.call(this);
    this.symbols.sleep = function(time, fn) {
      return setTimeout(fn, time);
    };
    this.phase = Phase.Initial;
    this.on('error', (function(_this) {
      return function(err) {
        console.log(err);
        throw err;
      };
    })(this));
    this._seq(this._loadScript);
  }

  Script.prototype.methodMissing = function(name) {
    return (function(_this) {
      return function() {
        var args, ref, val;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        log.d("method missing: " + name + ", " + (JSON.stringify(args)));
        val = (ref = _this.project).methodMissing.apply(ref, [name].concat(slice.call(args)));
        if (val != null) {
          return val;
        }
        if (!args.length) {
          return [name];
        }
        if (args.length === 1) {
          args = args[0];
        }
        return [name, args];
      };
    })(this);
  };

  Script.prototype.propertyMissing = function(name) {
    log.d("property missing: " + name);
    return name;
  };

  Script.prototype.initialize = function() {
    return this._seq(this._initialize);
  };

  Script.prototype.configure = function() {
    return this._seq(this._configure);
  };

  Script.prototype.execute = function() {
    return this._seq(this._execute);
  };

  Script.prototype._loadScript = function() {
    return walkup('build.kohi', {
      cwd: process.cwd()
    }).then((function(_this) {
      return function(v) {
        if (!v.length) {
          throw new Error("Didn't find file build.kohi");
        }
        log.v('loadScript:', v[0]);
        _this.scriptFile = path.join(v[0].dir, v[0].files[0]);
        return readFile(_this.scriptFile, 'utf8');
      };
    })(this)).then((function(_this) {
      return function(contents) {
        return _this.contents = contents;
      };
    })(this));
  };

  Script.prototype._initialize = function() {
    log.v('initialize');
    this.phase = Phase.Initialization;
    this.project = this._createProject();
    this.context.push(this.project);
    return this.project.initialize();
  };

  Script.prototype._createProject = function() {
    var name, parts, project, projectDir;
    parts = path.parse(this.scriptFile);
    projectDir = parts.dir;
    name = path.basename(projectDir);
    project = new Project({
      script: this,
      name: name,
      projectDir: projectDir
    });
    return project;
  };

  Script.prototype._configure = function() {
    log.v('configure');
    this.phase = Phase.Configuration;
    this.evaluate(this.contents);
    return this.project.configure();
  };

  Script.prototype._execute = function() {
    log.v('execute');
    this.phase = Phase.Execution;
    return this.project.execute();
  };

  return Script;

})(multi(CoffeeDsl, SeqX));

module.exports = Script;
