var FileSourceSet, Q, _, glob, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Q = require('q');

_ = require('lodash');

rek = require('rekuire');

glob = rek('lib/util/glob');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

FileSourceSet = (function() {
  function FileSourceSet(arg) {
    this.spec = (arg != null ? arg : {}).spec;
    this.resolve = bind(this.resolve, this);
    this.opts = {
      nodir: true,
      realpath: true
    };
  }

  FileSourceSet.prototype.resolve = function(resolver) {
    var children, files, res, s;
    res = {
      includes: [],
      excludes: []
    };
    files = [];
    if (this.spec.children != null) {
      children = Q.all((function() {
        var i, len, ref, results;
        ref = this.spec.children;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          s = ref[i];
          results.push(new FileSourceSet({
            spec: s
          }).resolve(resolver));
        }
        return results;
      }).call(this));
    } else {
      children = Q([]);
    }
    return children.then((function(_this) {
      return function(list) {
        var all, dir, opts, srcDir;
        files.push(_.flatten(list));
        srcDir = _this.spec.srcDir || '.';
        dir = resolver.file(srcDir);
        opts = _.extend({}, _this.opts);
        opts.cwd = dir;
        all = [];
        ['includes', 'excludes'].forEach(function(t) {
          if (_this.spec[t]) {
            return _this.spec[t].forEach(function(pat) {
              return all.push(glob(pat, opts).then(function(list) {
                return res[t].push(list);
              }));
            });
          }
        });
        return Q.all(all).then(function() {
          files = files.concat(_.flatten(res.includes));
          return _.difference(files, _.flatten(res.excludes));
        });
      };
    })(this)).then((function(_this) {
      return function(files) {
        return _this.files = _.uniq(_.flatten(files));
      };
    })(this));
  };

  return FileSourceSet;

})();

module.exports = FileSourceSet;
