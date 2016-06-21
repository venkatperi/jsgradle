var Plugin, ProxyFactory, SourceSetContainer, SourceSetsPlugin, out, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

rek = require('rekuire');

out = rek('out');

ProxyFactory = rek('ProxyFactory');

SourceSetContainer = rek('SourceSetContainer');

SourceSetsPlugin = (function(superClass) {
  extend(SourceSetsPlugin, superClass);

  function SourceSetsPlugin() {
    this.doApply = bind(this.doApply, this);
    return SourceSetsPlugin.__super__.constructor.apply(this, arguments);
  }

  SourceSetsPlugin.prototype.doApply = function() {
    this.sourceSets = new SourceSetContainer({
      parent: this.project,
      name: 'root'
    });
    return this.register({
      extensions: {
        sourceSets: this.sourceSets
      }
    });
  };

  return SourceSetsPlugin;

})(Plugin);

module.exports = SourceSetsPlugin;
