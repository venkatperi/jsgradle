var CacheSwap, FileCache, Q, _, conf, methods, path, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

CacheSwap = require('cache-swap');

rek = require('rekuire');

conf = rek('conf');

Q = require('q');

_ = require('lodash');

path = require('path');

methods = {
  has: 'hasCached',
  set: 'addCached',
  get: 'getCached',
  "delete": 'removeCached'
};

FileCache = (function(superClass) {
  extend(FileCache, superClass);

  function FileCache(opts) {
    var fn, k, tmpDir, v;
    if (opts == null) {
      opts = {};
    }
    tmpDir = conf.get('project:cache:cacheDir');
    opts = _.extend({}, {
      tmpDir: tmpDir
    }, opts);
    FileCache.__super__.constructor.call(this, opts);
    this.category = opts.category || 'default';
    this.cacheDir = path.join(tmpDir, opts.cacheDirName, this.category);
    fn = (function(_this) {
      return function(k, v) {
        return _this[k] = function() {
          var args, ref;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          return Q.nmapply(_this, v, (ref = [_this.category]).concat.apply(ref, args));
        };
      };
    })(this);
    for (k in methods) {
      if (!hasProp.call(methods, k)) continue;
      v = methods[k];
      fn(k, v);
    }
  }

  return FileCache;

})(CacheSwap);

module.exports = FileCache;
