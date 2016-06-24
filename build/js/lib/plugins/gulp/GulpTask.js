var CachingTask, CountFiles, GulpAction, GulpSpec, GulpTask, _, changeExt, conf, gulp, path, rek, requireInstall,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

CachingTask = rek('lib/task/CachingTask');

gulp = require('gulp');

GulpSpec = rek('GulpSpec');

GulpAction = require('./GulpAction');

conf = rek('conf');

path = require('path');

changeExt = rek('fileOps').changeExt;

CountFiles = rek('CountFiles');

requireInstall = rek('require-install');

GulpTask = (function(superClass) {
  extend(GulpTask, superClass);

  function GulpTask() {
    this._createSpec = bind(this._createSpec, this);
    this._onAfterEvaluate = bind(this._onAfterEvaluate, this);
    this.outputName = bind(this.outputName, this);
    this.setChild = bind(this.setChild, this);
    return GulpTask.__super__.constructor.apply(this, arguments);
  }

  GulpTask._addProperties({
    optional: ['spec', 'output', 'base', 'outputExt', 'package']
  });

  GulpTask.prototype.setChild = function(c) {
    return this.spec.setChild(c);
  };

  GulpTask.prototype.outputName = function(inputName) {
    var out;
    out = path.join(this.targetDir, inputName);
    if (this.outputExt) {
      changeExt(out, "." + this.outputExt);
    }
    return out;
  };

  GulpTask.prototype._onAfterEvaluate = function() {
    return this.changedFiles.then((function(_this) {
      return function(files) {
        var counter, dest, modified, plugin, srcOpts;
        if (files == null) {
          return;
        }
        modified = _.union(files.added, files.changed);
        _this.stats.files = files.all.length;
        if (!(modified.length > 0)) {
          _this.stats.cached = files.all.length;
          return;
        }
        srcOpts = {};
        if (_this.base) {
          srcOpts.base = _this.base;
        }
        dest = _this.targetDir;
        if (!dest) {
          throw new Error("No destinations");
        }
        counter = new CountFiles();
        counter.on('count', function(count) {
          return _this.stats.cached = _this.stats.files - count;
        });
        plugin = requireInstall(_this["package"])(_this.options);
        plugin.on('error', function(err) {
          throw err;
        });
        gulp.task(_this.path, function() {
          return gulp.src(modified, srcOpts).pipe(counter.plugin).pipe(plugin).pipe(gulp.dest(dest));
        });
        return _this.doFirst(new GulpAction({
          gulp: gulp,
          taskName: _this.path,
          task: _this
        }));
      };
    })(this));
  };

  GulpTask.prototype._createSpec = function() {
    return this.spec != null ? this.spec : this.spec = new GulpSpec();
  };

  return GulpTask;

})(CachingTask);

module.exports = GulpTask;
