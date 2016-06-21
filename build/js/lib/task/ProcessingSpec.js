var ProcessingSpec, log,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

log = require('../util/logger')('ProcessingSpec');

ProcessingSpec = (function() {
  function ProcessingSpec() {
    this.rename = bind(this.rename, this);
    this.eachFile = bind(this.eachFile, this);
    this.duplicatesStrategy = bind(this.duplicatesStrategy, this);
    this.includeEmptyDirs = bind(this.includeEmptyDirs, this);
    this.filter = bind(this.filter, this);
  }

  ProcessingSpec.prototype.filter = function(f) {
    if (this.filters == null) {
      this.filters = [];
    }
    return this.filters.push(f);
  };

  ProcessingSpec.prototype.includeEmptyDirs = function(v) {
    return this._includeEmptyDirs = v;
  };

  ProcessingSpec.prototype.duplicatesStrategy = function(v) {
    return this._duplicatesStrategy = v;
  };

  ProcessingSpec.prototype.eachFile = function(f) {
    if (this.fileActions == null) {
      this.fileActions = [];
    }
    return this.fileActions.push(f);
  };

  ProcessingSpec.prototype.rename = function(f) {
    if (this.srcNameActions == null) {
      this.srcNameActions = [];
    }
    return this.srcNameActions.push(f);
  };

  return ProcessingSpec;

})();

module.exports = ProcessingSpec;
