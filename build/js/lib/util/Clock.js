var Clock, pretty, prop,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

pretty = require('pretty-hrtime');

prop = require('./prop');

Clock = (function() {
  prop(Clock, 'time', {
    get: function() {
      return process.hrtime(this.start);
    }
  });

  prop(Clock, 'pretty', {
    get: function() {
      return pretty(this.time);
    }
  });

  function Clock() {
    this.reset = bind(this.reset, this);
    this.reset();
  }

  Clock.prototype.reset = function() {
    return this.start = process.hrtime();
  };

  return Clock;

})();

module.exports = Clock;
