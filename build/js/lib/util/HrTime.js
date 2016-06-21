var HrTime, pretty, prop,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

pretty = require('pretty-hrtime');

prop = require('./prop');

HrTime = (function() {
  function HrTime(opts) {
    if (opts == null) {
      opts = {};
    }
    this.toString = bind(this.toString, this);
    this.mark = bind(this.mark, this);
    if (!opts.manual) {
      this.mark();
    }
  }

  HrTime.prototype.mark = function() {
    if (!this.start) {
      return this.start = process.hrtime();
    } else if (!this.end) {
      return this.end = process.hrtime(this.start);
    } else {
      throw new Error("Both start/end already set");
    }
  };

  HrTime.prototype.toString = function() {
    return pretty(this.end);
  };

  return HrTime;

})();

module.exports = HrTime;
