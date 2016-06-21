var Reporter, _, events,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

_ = require('lodash');

events = ['script:initialize:start', 'script:initialize:end', 'script:configure:start', 'script:configure:end', 'script:afterEvaluate:start', 'script:afterEvaluate:end', 'script:execute:start', 'script:execute:end', 'project:initialize:start', 'project:initialize:end', 'project:configure:start', 'project:configure:end', 'project:afterEvaluate:start', 'project:afterEvaluate:end', 'project:execute:start', 'project:execute:end', 'task:initialize:start', 'task:initialize:end', 'task:configure:start', 'task:configure:end', 'task:afterEvaluate:start', 'task:afterEvaluate:end', 'task:execute:start', 'task:execute:end', 'action:initialize:start', 'action:initialize:end', 'action:configure:start', 'action:configure:end', 'action:execute:start', 'action:execute:end'];

Reporter = (function() {
  function Reporter(opts) {
    if (opts == null) {
      opts = {};
    }
    this.listenTo = bind(this.listenTo, this);
  }

  Reporter.prototype.listenTo = function(obj) {
    var e, handler, i, len, results;
    obj.on('error', this.onError);
    results = [];
    for (i = 0, len = events.length; i < len; i++) {
      e = events[i];
      handler = 'on' + _.map(e.split(':'), function(x) {
        return _.upperFirst(x);
      }).join('');
      if (this[handler] != null) {
        results.push(obj.on(e, this[handler]));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return Reporter;

})();

module.exports = Reporter;
