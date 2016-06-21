var Action, CopyAction, copyFile, log, os, path, split,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

os = require('os');

Action = require('../Action');

path = require('path');

log = require('../../util/logger')('CopyAction');

copyFile = require('../../util/fileOps').copyFile;

split = require('split');

CopyAction = (function(superClass) {
  extend(CopyAction, superClass);

  function CopyAction(src1, dest1, copySpec, opts1) {
    this.src = src1;
    this.dest = dest1;
    this.copySpec = copySpec;
    this.opts = opts1;
    this.exec = bind(this.exec, this);
  }

  CopyAction.prototype.exec = function() {
    var cwd, dest, f, filters, i, len, noEOL, opts, ref, src;
    cwd = this.opts.cwd || process.cwd();
    src = this.src[0] === path.sep ? this.src : path.join(cwd, this.src);
    ref = this.copySpec.srcNameActions;
    for (i = 0, len = ref.length; i < len; i++) {
      f = ref[i];
      src = f(src);
    }
    dest = path.join(cwd, this.dest, this.src);
    log.v("copy: " + src + " -> " + dest);
    opts = {};
    if (this.copySpec.filters.length > 0) {
      noEOL = this.opts.noEOL;
      filters = this.copySpec.filters;
      opts.transform = function(rs, ws, file) {
        var stream;
        stream = rs;
        filters.forEach(function(f) {
          var _f;
          _f = function(line) {
            var out;
            out = f(line);
            if (!noEOL) {
              out += os.EOL;
            }
            return out;
          };
          return stream = stream.pipe(split(_f));
        });
        return stream.pipe(ws);
      };
    }
    return copyFile(src, dest, opts);
  };

  return CopyAction;

})(Action);

module.exports = CopyAction;
