var Clock, pretty, prop;

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
    this.start = process.hrtime();
  }

  return Clock;

})();

module.exports = Clock;
