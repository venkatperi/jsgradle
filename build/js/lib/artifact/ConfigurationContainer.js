var Collection, ConfigurationContainer, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Collection = rek('Collection');

ConfigurationContainer = (function(superClass) {
  extend(ConfigurationContainer, superClass);

  function ConfigurationContainer() {
    return ConfigurationContainer.__super__.constructor.apply(this, arguments);
  }

  return ConfigurationContainer;

})(Collection);

module.exports = ConfigurationContainer;
