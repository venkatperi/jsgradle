var Action, FileAction, changeExt, path, readFile, ref, rek, writeFileMkdir,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

path = require('path');

rek = require('rekuire');

Action = rek('Action');

ref = rek('fileOps'), readFile = ref.readFile, writeFileMkdir = ref.writeFileMkdir, changeExt = ref.changeExt;

FileAction = (function(superClass) {
  extend(FileAction, superClass);

  function FileAction(opts) {
    var f, i, len, ref1;
    if (opts == null) {
      opts = {};
    }
    this.execSync = bind(this.execSync, this);
    ref1 = ['transform', 'src', 'dest', 'opts', 'srcDir', 'ext', 'spec'];
    for (i = 0, len = ref1.length; i < len; i++) {
      f = ref1[i];
      if (!opts[f]) {
        continue;
      }
      this[f] = opts[f];
      delete opts[f];
    }
    FileAction.__super__.constructor.call(this, opts);
  }

  FileAction.prototype.execSync = function() {
    var dest, rel;
    rel = path.relative(this.srcDir, this.src);
    dest = path.join(this.dest, this.spec.srcDir, rel);
    if (this.ext != null) {
      dest = changeExt(dest, this.ext);
    }
    return readFile(this.src, 'utf8').then((function(_this) {
      return function(source) {
        var output;
        if (_this.transform) {
          output = _this.transform(source, _this.opts);
        } else {
          output = source;
        }
        _this.task.didWork++;
        return writeFileMkdir(dest, output);
      };
    })(this));
  };

  return FileAction;

})(Action);

module.exports = FileAction;
