var GulpPlugin, GulpTask, Plugin, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Plugin = require('./Plugin');

GulpTask = rek('GulpTask');

GulpPlugin = (function(superClass) {
  extend(GulpPlugin, superClass);

  function GulpPlugin() {
    this.doApply = bind(this.doApply, this);
    return GulpPlugin.__super__.constructor.apply(this, arguments);
  }

  GulpPlugin.prototype.doApply = function() {
    return this.register({
      taskFactory: {
        GulpCoffee: GulpTask
      }
    });
  };

  return GulpPlugin;

})(Plugin);

module.exports = GulpPlugin;
