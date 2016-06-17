var SourceSpec,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  slice = [].slice;

SourceSpec = (function() {
  function SourceSpec(src) {
    this.src = src;
    this.toString = bind(this.toString, this);
    this.exclude = bind(this.exclude, this);
    this.include = bind(this.include, this);
    this.includes = [];
    this.excludes = [];
  }

  SourceSpec.prototype.include = function() {
    var i, items, j, len, results;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    results = [];
    for (j = 0, len = items.length; j < len; j++) {
      i = items[j];
      results.push(this.includes.push(i));
    }
    return results;
  };

  SourceSpec.prototype.exclude = function() {
    var i, items, j, len, results;
    items = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    results = [];
    for (j = 0, len = items.length; j < len; j++) {
      i = items[j];
      results.push(this.excludes.push(i));
    }
    return results;
  };

  SourceSpec.prototype.toString = function() {
    return "SourceSpec{src: " + this.src + ", includes: " + this.includes + ", excludes: " + this.excludes;
  };

  return SourceSpec;

})();

module.exports = SourceSpec;
