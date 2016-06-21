var Action, BaseObject, CachingTask, FileCache, GlobChanges, Path, Task, TaskStats, conf, os, p, rek, sha1,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

os = require('os');

p = rek('lib/util/prop');

Path = require('./../common/Path');

Action = require('./Action');

BaseObject = rek('BaseObject');

conf = rek('conf');

Task = rek('Task');

TaskStats = require('./TaskStats');

FileCache = rek('FileCache');

sha1 = require('sha1');

GlobChanges = require('glob-changes').GlobChanges;

CachingTask = (function(superClass) {
  extend(CachingTask, superClass);

  function CachingTask() {
    this._createSpec = bind(this._createSpec, this);
    this._init = bind(this._init, this);
    this.cacheOptions = bind(this.cacheOptions, this);
    this.didOptionsChange = bind(this.didOptionsChange, this);
    this.configure = bind(this.configure, this);
    return CachingTask.__super__.constructor.apply(this, arguments);
  }

  CachingTask._addProperties({
    optional: ['noCache']
  });

  p(CachingTask, 'targetDir', {
    get: function() {
      var dest, ref, ref1;
      dest = this.output;
      if (dest == null) {
        dest = (ref = this.spec) != null ? (ref1 = ref.allDest) != null ? ref1[0] : void 0 : void 0;
      }
      return dest;
    }
  });

  p(CachingTask, 'fileCache', {
    get: function() {
      return this._cache.get('fileCache', (function(_this) {
        return function() {
          return new FileCache({
            cacheDirName: 'cache',
            category: _this.name
          });
        };
      })(this));
    }
  });

  p(CachingTask, 'cacheDir', {
    get: function() {
      return this._cache.get('cacheDir', (function(_this) {
        return function() {
          return _this.project.fileResolver.file(_this.fileCache.cacheDir);
        };
      })(this));
    }
  });

  p(CachingTask, 'changedFiles', {
    get: function() {
      return new GlobChanges({
        fileCache: this.fileCache
      }).changes(this.name, this.spec.patterns, {
        realpath: true
      });
    }
  });

  CachingTask.prototype.configure = function() {
    return this.didOptionsChange();
  };

  CachingTask.prototype.didOptionsChange = function() {
    var hash, name;
    name = "clearCache" + this.capitalizedName;
    hash = sha1(JSON.stringify(this.options));
    return this.fileCache.get(hash).then((function(_this) {
      return function(v) {
        if (v != null) {
          return;
        }
        _this.dependsOn(name);
        return _this.cacheOptions();
      };
    })(this));
  };

  CachingTask.prototype.cacheOptions = function() {
    if (!this.options) {
      return;
    }
    return this.doLast((function(_this) {
      return function() {
        var hash, opt;
        opt = JSON.stringify(_this.options);
        hash = sha1(opt);
        return _this.fileCache.set(hash, opt);
      };
    })(this));
  };

  CachingTask.prototype._init = function() {
    CachingTask.__super__._init.call(this);
    return this._createSpec();
  };

  CachingTask.prototype._createSpec = function() {
    return this.spec != null ? this.spec : this.spec = new FileSpec();
  };

  return CachingTask;

})(Task);

module.exports = CachingTask;
