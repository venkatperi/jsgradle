var Action, UpdatePkgAction, ensureOptions, prop, rek, writeFile,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Action = rek('lib/task/Action');

prop = rek('prop');

writeFile = rek('fileOps').writeFile;

ensureOptions = rek('validate').ensureOptions;

UpdatePkgAction = (function(superClass) {
  extend(UpdatePkgAction, superClass);

  function UpdatePkgAction() {
    this.exec = bind(this.exec, this);
    this._init = bind(this._init, this);
    return UpdatePkgAction.__super__.constructor.apply(this, arguments);
  }

  UpdatePkgAction.prototype._init = function(opts) {
    var ref;
    if (opts == null) {
      opts = {};
    }
    return ref = ensureOptions(opts, 'filename', 'pkg'), this.filename = ref.filename, this.pkg = ref.pkg, ref;
  };

  UpdatePkgAction.prototype.exec = function(resolve) {
    var data;
    data = JSON.stringify(this.pkg, null, 2);
    return resolve(writeFile(this.filename, data, 'utf8')).then((function(_this) {
      return function() {
        return _this.task.didWork++;
      };
    })(this));
  };

  return UpdatePkgAction;

})(Action);

module.exports = UpdatePkgAction;
