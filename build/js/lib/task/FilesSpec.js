var Collection, CopySpec, _, path, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

_ = require('lodash');

rek = require('rekuire');

prop = rek('prop');

path = require('path');

Collection = rek('Collection');

CopySpec = (function(superClass) {
  extend(CopySpec, superClass);

  function CopySpec() {
    this.rename = bind(this.rename, this);
    this.eachFile = bind(this.eachFile, this);
    this.duplicatesStrategy = bind(this.duplicatesStrategy, this);
    this.includeEmptyDirs = bind(this.includeEmptyDirs, this);
    this.filter = bind(this.filter, this);
    this.into = bind(this.into, this);
    this.from = bind(this.from, this);
    this.exclude = bind(this.exclude, this);
    this.include = bind(this.include, this);
    this["with"] = bind(this["with"], this);
    this.caseSensitive = bind(this.caseSensitive, this);
    this.loadFrom = bind(this.loadFrom, this);
    this._init = bind(this._init, this);
    return CopySpec.__super__.constructor.apply(this, arguments);
  }

  prop(CopySpec, 'allOptions', {
    get: function() {
      var list;
      list = [];
      this.forEach(function(c) {
        return list.push((c.__factory === 'options' ? c : c.allOptions));
      });
      return _.flatten(list);
    }
  });

  prop(CopySpec, 'allDest', {
    get: function() {
      var list;
      list = this.map(function(c) {
        return c.allDest;
      });
      if (this.dest != null) {
        list.push(this.dest);
      }
      return _.flatten(list);
    }
  });

  prop(CopySpec, 'patterns', {
    get: function() {
      var patterns, src;
      src = (this.srcDir + "/") || '';
      patterns = _.map(_.flatten(this.map(function(c) {
        return c.patterns;
      })), function(x) {
        var prefix, ref;
        prefix = '';
        if (x[0] === '!') {
          ref = [x.slice(1), '!'], x = ref[0], prefix = ref[1];
        }
        return "" + prefix + src + x;
      });
      patterns = patterns.concat(_.map(this.includes, function(x) {
        return "" + src + x;
      }));
      patterns = patterns.concat(_.map(this.excludes, function(x) {
        return "!" + src + x;
      }));
      return _.map(patterns, function(x) {
        var prefix, ref;
        prefix = '';
        if (x[0] === '!') {
          ref = [x.slice(1), '!'], x = ref[0], prefix = ref[1];
        }
        return prefix + path.normalize(x);
      });
    }
  });

  CopySpec._addProperties({
    optional: ['srcDir', 'dest', 'includes', 'excludes'],
    exportedMethods: ['caseSensitive', 'with', 'include', 'exclude', 'from', 'into']
  });

  CopySpec.prototype._init = function(opts) {
    if (opts == null) {
      opts = {};
    }
    CopySpec.__super__._init.call(this, opts);
    if (opts.from != null) {
      this.loadFrom(opts.from);
    }
    if (opts.filter != null) {
      if (this.filters == null) {
        this.filters = [];
      }
      this.filters.push(opts.filter);
    }
    return this.srcDir != null ? this.srcDir : this.srcDir = '.';
  };

  CopySpec.prototype.loadFrom = function(from) {
    var i, j, k, len, len1, ref, ref1, results;
    if (from.srcDir) {
      this.srcDir = from.srcDir;
    }
    if (from.includes) {
      ref = from.includes;
      for (j = 0, len = ref.length; j < len; j++) {
        i = ref[j];
        this.include(i);
      }
    }
    if (from.excludes) {
      ref1 = from.excludes;
      results = [];
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        i = ref1[k];
        results.push(this.exclude(i));
      }
      return results;
    }
  };

  CopySpec.prototype.caseSensitive = function(val) {
    return this._caseSensitive = val;
  };

  CopySpec.prototype["with"] = function() {
    var j, len, results, s, srcs;
    srcs = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    results = [];
    for (j = 0, len = srcs.length; j < len; j++) {
      s = srcs[j];
      results.push(this.sources.push(s));
    }
    return results;
  };

  CopySpec.prototype.include = function() {
    var i, items, j, len, ref, results;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (this.includes == null) {
      this.includes = [];
    }
    ref = _.flatten(items);
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      results.push(this.includes.push(i));
    }
    return results;
  };

  CopySpec.prototype.exclude = function() {
    var i, items, j, len, ref, results;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (this.excludes == null) {
      this.excludes = [];
    }
    ref = _.flatten(items);
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      results.push(this.excludes.push(i));
    }
    return results;
  };

  CopySpec.prototype.from = function(src, f) {
    var item, ref;
    item = new CopySpec({
      srcDir: src,
      parent: this
    });
    if (f) {
      if ((ref = this.root) != null) {
        ref.callScriptMethod(item, f);
      }
    }
    return this.setChild(item);
  };

  CopySpec.prototype.into = function(dir) {
    return this.dest = dir;
  };

  CopySpec.prototype.filter = function(f) {
    if (this.filters == null) {
      this.filters = [];
    }
    return this.filters.push(f);
  };

  CopySpec.prototype.includeEmptyDirs = function(v) {
    return this._includeEmptyDirs = v;
  };

  CopySpec.prototype.duplicatesStrategy = function(v) {
    return this._duplicatesStrategy = v;
  };

  CopySpec.prototype.eachFile = function(f) {
    if (this.fileActions == null) {
      this.fileActions = [];
    }
    return this.fileActions.push(f);
  };

  CopySpec.prototype.rename = function(f) {
    if (this.srcNameActions == null) {
      this.srcNameActions = [];
    }
    return this.srcNameActions.push(f);
  };

  return CopySpec;

})(Collection);

module.exports = CopySpec;
