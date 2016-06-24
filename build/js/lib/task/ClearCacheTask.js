var ClearCacheTask, RmdirTask, _,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

RmdirTask = require('./RmdirTask');

ClearCacheTask = (function(superClass) {
  extend(ClearCacheTask, superClass);

  function ClearCacheTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    return ClearCacheTask.__super__.constructor.apply(this, arguments);
  }

  ClearCacheTask._addProperties({
    optional: ['target']
  });

  ClearCacheTask.prototype.onAfterEvaluate = function() {
    var dir;
    if (this.dirs == null) {
      this.dirs = [];
    }
    if (this.target) {
      dir = this.project.tasks.get(this.target).task.cacheDir;
    } else {
      dir(this.project.cacheDir);
    }
    if (dir != null) {
      this.dirs.push(dir);
    }
    return ClearCacheTask.__super__.onAfterEvaluate.call(this);
  };

  return ClearCacheTask;

})(RmdirTask);

module.exports = ClearCacheTask;
