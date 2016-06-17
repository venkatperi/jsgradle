var Action, CopyAction, path,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Action = require('../Action');

path = require('path');

CopyAction = (function(superClass) {
  extend(CopyAction, superClass);

  function CopyAction(src1, dest1, opts) {
    this.src = src1;
    this.dest = dest1;
    this.opts = opts;
    this.exec = bind(this.exec, this);
  }

  CopyAction.prototype.exec = function() {
    var cwd, dest, src;
    cwd = this.opts.cwd || process.cwd();
    src = this.src[0] === path.sep ? this.src : path.join(cwd, this.src);
    dest = path.join(cwd, this.dest);
    return console.log("copy: " + src + " -> " + dest);
  };

  return CopyAction;

})(Action);

module.exports = CopyAction;
