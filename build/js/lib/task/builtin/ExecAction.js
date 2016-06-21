var Action, ExecAction, execFile, out,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Action = require('../Action');

out = require('../../util/out');

execFile = require('child_process').execFile;

ExecAction = (function(superClass) {
  extend(ExecAction, superClass);

  function ExecAction(opts) {
    if (opts == null) {
      opts = {};
    }
    this.exec = bind(this.exec, this);
    this.spec = opts.spec;
    ExecAction.__super__.constructor.call(this, opts);
  }

  ExecAction.prototype.exec = function(resolve, reject) {
    var opts;
    opts = {};
    if (this.spec._env != null) {
      opts.env = this.spec._env;
    }
    if (this.spec._workingDir != null) {
      opts.cwd = this.spec._workingDir;
    }
    return execFile(this.spec._executable, this.spec._args, opts, (function(_this) {
      return function(e, stdout, stderr) {
        if (e) {
          _this.spec.execResult = e;
          if (!_this.spec._ignoreExitValue) {
            return reject((function() {
              switch (e.code) {
                case 'ENOENT':
                  return new Error(e.cmd + ": command not found");
                default:
                  return e;
              }
            })());
          }
        }
        if (stdout != null) {
          _this.println(stdout);
        }
        if (stderr != null) {
          _this.println(stderr);
        }
        return resolve();
      };
    })(this));
  };

  return ExecAction;

})(Action);

module.exports = ExecAction;
