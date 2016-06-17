var Collection, PluginsRegistry, _, fs, path, pluginRegex,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

fs = require('fs');

path = require('path');

_ = require('lodash');

Collection = require('../util/Collection');

pluginRegex = /(\w+)Plugin\.coffee/;

PluginsRegistry = (function(superClass) {
  extend(PluginsRegistry, superClass);

  function PluginsRegistry() {
    this._loadInternal = bind(this._loadInternal, this);
    PluginsRegistry.__super__.constructor.call(this, {
      convertName: function(x) {
        return _.lowerFirst(x);
      }
    });
    this._loadInternal();
  }

  PluginsRegistry.prototype._loadInternal = function() {
    var dir, f, files, i, len, name, plugin, results;
    dir = path.join(__dirname, '../plugins');
    files = _.filter(fs.readdirSync(dir), function(x) {
      return x.match(pluginRegex);
    });
    results = [];
    for (i = 0, len = files.length; i < len; i++) {
      f = files[i];
      name = f.match(pluginRegex)[1];
      plugin = require(path.join(dir, f));
      results.push(this.add(name, plugin));
    }
    return results;
  };

  return PluginsRegistry;

})(Collection);

module.exports = PluginsRegistry;
