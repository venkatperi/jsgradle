var CopySpec, SourceSpec,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

SourceSpec = require('./SourceSpec');

CopySpec = (function(superClass) {
  extend(CopySpec, superClass);

  function CopySpec() {
    this.toString = bind(this.toString, this);
    this["with"] = bind(this["with"], this);
    this.rename = bind(this.rename, this);
    this.eachFile = bind(this.eachFile, this);
    this.duplicatesStrategy = bind(this.duplicatesStrategy, this);
    this.includeEmptyDirs = bind(this.includeEmptyDirs, this);
    this.caseSensitive = bind(this.caseSensitive, this);
    this.filter = bind(this.filter, this);
    this.into = bind(this.into, this);
    this.from = bind(this.from, this);
    CopySpec.__super__.constructor.call(this);
    this.fileActions = [];
    this.filters = [];
    this.sources = [];
    this.destinations = [];
    this.childSpecs = [];
  }

  CopySpec.prototype.from = function(src, f) {
    var sourceSpec;
    sourceSpec = new SourceSpec(src);
    if (f) {
      this.runWith(f, sourceSpec);
    }
    return this.sources.push(sourceSpec);
  };

  CopySpec.prototype.into = function(spec) {
    return this.destinations.push(spec);
  };

  CopySpec.prototype.filter = function(f) {
    return this.filters.push(f);
  };

  CopySpec.prototype.caseSensitive = function(v) {
    return this._caseSensitive = v;
  };

  CopySpec.prototype.includeEmptyDirs = function(v) {
    return this._includeEmptyDirs = v;
  };

  CopySpec.prototype.duplicatesStrategy = function(v) {
    return this._duplicatesStrategy = v;
  };

  CopySpec.prototype.eachFile = function(f) {
    return this.fileActions.push(f);
  };

  CopySpec.prototype.rename = function(f) {
    return this._rename = f;
  };

  CopySpec.prototype["with"] = function(child) {
    return this.childSpecs.push(child);
  };

  CopySpec.prototype.toString = function() {
    var out;
    out = ['CopySpec'];
    out.push("  from: " + this.sources);
    out.push("  into: " + this.destinations);
    return out.join('\n');
  };

  return CopySpec;

})(SourceSpec);

module.exports = CopySpec;
