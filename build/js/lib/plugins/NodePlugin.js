var NodeConvention, NodePlugin, Plugin, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Plugin = require('./Plugin');

NodeConvention = rek('NodeConvention');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

NodePlugin = (function(superClass) {
  extend(NodePlugin, superClass);

  function NodePlugin() {
    this.doApply = bind(this.doApply, this);
    return NodePlugin.__super__.constructor.apply(this, arguments);
  }

  NodePlugin.prototype.doApply = function() {
    return this.register({
      conventions: {
        node: NodeConvention
      }
    });
  };

  return NodePlugin;

})(Plugin);

module.exports = NodePlugin;
