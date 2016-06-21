var CopyAction, CopySpec, CopyTask, FileTask, _, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

FileTask = require('../FileTask');

CopySpec = rek('FilesSpec');

CopyAction = require('./CopyAction');

CopyTask = (function(superClass) {
  extend(CopyTask, superClass);

  function CopyTask() {
    this.setChild = bind(this.setChild, this);
    this._init = bind(this._init, this);
    return CopyTask.__super__.constructor.apply(this, arguments);
  }

  CopyTask.prototype._init = function(opts) {
    if (opts == null) {
      opts = {};
    }
    opts = _.extend(opts, {
      spec: new CopySpec(),
      actionType: CopyAction
    });
    return CopyTask.__super__._init.call(this, opts);
  };

  CopyTask.prototype.setChild = function(child) {
    return this.spec.setChild(child);
  };

  return CopyTask;

})(FileTask);

module.exports = CopyTask;
