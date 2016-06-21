var Collection, PluginContainer, prop, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

prop = rek('prop');

Collection = rek('lib/common/Collection');

PluginContainer = (function(superClass) {
  extend(PluginContainer, superClass);

  function PluginContainer() {
    return PluginContainer.__super__.constructor.apply(this, arguments);
  }

  return PluginContainer;

})(Collection);

module.exports = PluginContainer;
