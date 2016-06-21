var RmdirAction, RmdirTask, Task, _,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

Task = require('./Task');

RmdirAction = require('./RmdirAction');

RmdirTask = (function(superClass) {
  extend(RmdirTask, superClass);

  function RmdirTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    return RmdirTask.__super__.constructor.apply(this, arguments);
  }

  RmdirTask.prototype.onAfterEvaluate = function() {
    var dirs;
    if (this.dirs != null) {
      dirs = _.map(this.dirs, (function(_this) {
        return function(x) {
          return _this.project.fileResolver.file(x);
        };
      })(this));
      return this.doLast(new RmdirAction({
        dirs: dirs,
        task: this
      }));
    }
  };

  return RmdirTask;

})(Task);

module.exports = RmdirTask;
