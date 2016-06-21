var SourceSpec, _, log, path,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  slice = [].slice;

_ = require('lodash');

path = require('path');

log = require('../util/logger')('SourceSpec');

SourceSpec = (function() {
  function SourceSpec(arg) {
    this.parent = (arg != null ? arg : {}).parent;
    this.configure = bind(this.configure, this);
    this.exclude = bind(this.exclude, this);
    this.include = bind(this.include, this);
    this["with"] = bind(this["with"], this);
    this.caseSensitive = bind(this.caseSensitive, this);
    this.hasMethod = bind(this.hasMethod, this);
  }

  SourceSpec.prototype.hasMethod = function(name) {
    return name === 'include' || name === 'exclude' || name === 'caseSensitive';
  };

  SourceSpec.prototype.caseSensitive = function(val) {
    return this._caseSensitive = val;
  };

  SourceSpec.prototype["with"] = function() {
    var j, len, results, s, srcs;
    srcs = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    results = [];
    for (j = 0, len = srcs.length; j < len; j++) {
      s = srcs[j];
      results.push(this.sources.push(s));
    }
    return results;
  };

  SourceSpec.prototype.include = function() {
    var i, items, j, len, ref, results;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    log.v('include', items);
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

  SourceSpec.prototype.exclude = function() {
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

  SourceSpec.prototype.configure = function(run) {
    log.i('configure');
    if (this.parent != null) {
      this.srcDir = path.join(this.parent.srcDir, this.srcDir);
    }
    if (this.includes.length === 0) {
      this.includes.push('**/*');
    }
    this.sources.forEach(function(s) {
      return s.configure(run);
    });
    if (this.configClosure != null) {
      return run(this, this.configClosure);
    }
  };

  return SourceSpec;

})();

module.exports = SourceSpec;
