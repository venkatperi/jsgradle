var Action, BaseObject, CachingTask, FileCache, GlobChanges, Path, Task, TaskStats, conf, p, rek, sha1,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

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
    return CachingTask.__super__.constructor.apply(this, arguments);
  }

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
