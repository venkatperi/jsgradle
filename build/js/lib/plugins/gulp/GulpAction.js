var Action, GulpAction, rek, through,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Action = rek('Action');

through = require('through');

GulpAction = (function(superClass) {
  extend(GulpAction, superClass);

  function GulpAction() {
    this.exec = bind(this.exec, this);
    this._init = bind(this._init, this);
    return GulpAction.__super__.constructor.apply(this, arguments);
  }

  GulpAction.prototype._init = function(opts) {
    if (opts == null) {
      opts = {};
    }
    this.gulp = opts.gulp;
    return this.taskName = opts.taskName;
  };

  GulpAction.prototype.exec = function(resolve, reject) {
    return this.gulp.start(this.taskName, (function(_this) {
      return function(err, res) {
        if (err != null) {
          return reject(err);
        }
        return resolve(res);
      };
    })(this));
  };

  return GulpAction;

})(Action);

module.exports = GulpAction;
