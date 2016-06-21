var ChangedFiles, GlobChanges, GulpThrough, _, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

GulpThrough = rek('GulpThrough');

GlobChanges = require('glob-changes').GlobChanges;

ChangedFiles = (function(superClass) {
  extend(ChangedFiles, superClass);

  function ChangedFiles(opts) {
    var _opts, globber, i, len, p, ref;
    if (opts == null) {
      opts = {};
    }
    this.onData = bind(this.onData, this);
    ChangedFiles.__super__.constructor.call(this, opts);
    ref = ['name', 'patterns'];
    for (i = 0, len = ref.length; i < len; i++) {
      p = ref[i];
      if (!opts[p]) {
        throw new Error("Missing option: " + p);
      }
    }
    this.stats = {
      total: 0,
      modified: 0
    };
    _opts = _.extend({}, {
      realpath: true
    }, opts);
    globber = opts.globChanges || new GlobChanges(opts);
    this.ready = globber.changes(opts.name, opts.patterns, _opts).then((function(_this) {
      return function(files) {
        var f, j, len1, ref1;
        _this.modified = {};
        ref1 = _.union(files.added, files.changed);
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          f = ref1[j];
          _this.modified[f] = f;
        }
        return _this.removed = files.removed;
      };
    })(this));
  }

  ChangedFiles.prototype.onData = function(f, e) {
    return this.ready.then((function(_this) {
      return function() {
        _this.stats.total++;
        if (_this.modified[f.path]) {
          _this.stats.modified++;
          return f;
        }
      };
    })(this));
  };

  return ChangedFiles;

})(GulpThrough);

module.exports = ChangedFiles;
