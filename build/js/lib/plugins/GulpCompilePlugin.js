var CleanMainOutputTask, FilesSpec, GulpCompilePlugin, GulpTask, Plugin, SourceMapConvention, SourceSetContainer, SourceSetOutput, TaskFactory, _, assert, conf, configurable, path, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

Plugin = require('./Plugin');

SourceSetContainer = rek('SourceSetContainer');

SourceMapConvention = rek('SourceMapConvention');

FilesSpec = rek('FilesSpec');

SourceSetOutput = rek('SourceSetOutput');

CleanMainOutputTask = rek('CleanMainOutputTask');

TaskFactory = rek('TaskFactory');

GulpTask = rek('GulpTask');

assert = require('assert');

configurable = rek('configurable');

conf = rek('conf');

path = require('path');

prop = rek('prop');

GulpCompilePlugin = (function(superClass) {
  extend(GulpCompilePlugin, superClass);

  function GulpCompilePlugin() {
    this.doApply = bind(this.doApply, this);
    this._createCompileTask = bind(this._createCompileTask, this);
    this._createExt = bind(this._createExt, this);
    this._generateConventionClass = bind(this._generateConventionClass, this);
    return GulpCompilePlugin.__super__.constructor.apply(this, arguments);
  }

  prop(GulpCompilePlugin, 'config', {
    get: function() {
      return conf.get("plugins:" + this.name);
    }
  });

  GulpCompilePlugin.prototype._generateConventionClass = function() {
    var genDir, outFile, upperName;
    upperName = _.upperFirst(this.name);
    genDir = this.project.genDir;
    outFile = path.join(genDir, upperName + "Convention.coffee");
    this.project.templates.generate('GulpConventionClass', {
      name: upperName
    }, outFile);
    return require(outFile);
  };

  GulpCompilePlugin.prototype._createExt = function() {
    var ext;
    ext = configurable(this.project.callScriptMethod);
    return _.extend(ext, this.config.options, {});
  };

  GulpCompilePlugin.prototype._createCompileTask = function(opts) {
    var output, spec, taskOptions;
    output = this.project.getSourceSets().get("main.output." + this.name).dir;
    spec = this.project.getSourceSets().get("main." + this.name);
    taskOptions = _.omit(this.config, 'uses');
    if (taskOptions.options == null) {
      taskOptions.options = {};
    }
    _.extend(taskOptions.options, this.project.extensions.get(this.name));
    return new GulpTask(_.extend({}, opts, taskOptions, {
      output: output,
      spec: spec
    }));
  };

  GulpCompilePlugin.prototype.doApply = function() {
    var cleanTaskName, cleanTaskType, clearCacheTaskName, compileTaskName, compileTaskType, conventionKlass, obj, upperName;
    this.applyPlugin('build');
    this.applyPlugin('sourceSets');
    upperName = _.upperFirst(this.name);
    conventionKlass = this._generateConventionClass();
    compileTaskType = 'Compile' + upperName;
    compileTaskName = 'compile' + upperName;
    clearCacheTaskName = 'clearCache' + _.upperFirst(compileTaskName);
    cleanTaskType = 'Clean' + upperName;
    cleanTaskName = 'clean' + upperName;
    obj = {
      extensions: {},
      conventions: {},
      taskFactory: {}
    };
    obj.extensions[this.name] = this._createExt();
    obj.conventions[this.name] = conventionKlass;
    obj.taskFactory[compileTaskType] = this._createCompileTask;
    obj.taskFactory[cleanTaskType] = CleanMainOutputTask;
    this.register(obj);
    this.createTask(compileTaskName, {
      type: compileTaskType
    });
    this.createTask(clearCacheTaskName, {
      type: 'ClearCacheTask',
      target: compileTaskName
    });
    this.createTask(cleanTaskName, {
      type: cleanTaskType
    });
    this.task('build').dependsOn(compileTaskName);
    return this.task('clean').dependsOn(cleanTaskName);
  };

  return GulpCompilePlugin;

})(Plugin);

module.exports = GulpCompilePlugin;
