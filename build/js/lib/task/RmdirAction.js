var Action, Q, RmdirAction, _, ensureOptions, log, rek, rmdir,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

Q = require('q');

rek = require('rekuire');

Action = require('./Action');

rmdir = rek('fileOps').rmdir;

ensureOptions = rek('validate').ensureOptions;

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

RmdirAction = (function(superClass) {
  extend(RmdirAction, superClass);

  function RmdirAction(opts) {
    if (opts == null) {
      opts = {};
    }
    this.exec = bind(this.exec, this);
    this.dirs = ensureOptions(opts, 'dirs').dirs;
    RmdirAction.__super__.constructor.call(this, opts);
  }

  RmdirAction.prototype.exec = function(resolve) {
    return resolve(Q.all(_.map(this.dirs, (function(_this) {
      return function(x) {
        _this.task.didWork = true;
        return rmdir(x);
      };
    })(this))));
  };

  return RmdirAction;

})(Action);

module.exports = RmdirAction;
