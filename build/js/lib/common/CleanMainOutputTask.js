var CleanMainOutputTask, RmdirTask, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

RmdirTask = rek('RmdirTask');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

CleanMainOutputTask = (function(superClass) {
  extend(CleanMainOutputTask, superClass);

  function CleanMainOutputTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    return CleanMainOutputTask.__super__.constructor.apply(this, arguments);
  }

  CleanMainOutputTask.prototype.onAfterEvaluate = function() {
    return this.dirs != null ? this.dirs : this.dirs = [this.project.getSourceSets().get('main.output').dir];
  };

  return CleanMainOutputTask;

})(RmdirTask);

module.exports = CleanMainOutputTask;
