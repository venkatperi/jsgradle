var Convention, NodeConvention, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Convention = rek('Convention');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

NodeConvention = (function(superClass) {
  extend(NodeConvention, superClass);

  function NodeConvention() {
    this.createConfigurations = bind(this.createConfigurations, this);
    return NodeConvention.__super__.constructor.apply(this, arguments);
  }

  NodeConvention.prototype.createConfigurations = function() {
    var c, i, len, ref, results;
    ref = ['compile', 'production', 'test'];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      c = ref[i];
      if (!this.configurationExists(c)) {
        results.push(this.createConfiguration(c));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return NodeConvention;

})(Convention);

module.exports = NodeConvention;
