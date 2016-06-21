var Collection, PluginsRegistry, _, conf, fs, path, pluginRegex, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

fs = require('fs');

path = require('path');

_ = require('lodash');

Collection = rek('lib/common/Collection');

conf = rek('conf');

pluginRegex = /(\w+)Plugin\.coffee/;

PluginsRegistry = (function(superClass) {
  extend(PluginsRegistry, superClass);

  PluginsRegistry._addProperties({
    required: ['project']
  });

  function PluginsRegistry(opts) {
    if (opts == null) {
      opts = {};
    }
    this._loadGulpPlugins = bind(this._loadGulpPlugins, this);
    this._loadInternal = bind(this._loadInternal, this);
    PluginsRegistry.__super__.constructor.call(this, _.extend({}, opts, {
      convertName: function(x) {
        return _.lowerFirst(x);
      }
    }));
    this._loadInternal();
    this._loadGulpPlugins();
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

  PluginsRegistry.prototype._loadGulpPlugins = function() {
    var dest, destFile, k, plugin, ref, results, upper, v;
    ref = conf.get('plugins');
    results = [];
    for (k in ref) {
      if (!hasProp.call(ref, k)) continue;
      v = ref[k];
      if (!(v.uses === 'GulpCompilePlugin')) {
        continue;
      }
      upper = _.upperFirst(k);
      dest = this.project.fileResolver.file(conf.get('project:build:genDir'));
      destFile = path.join(dest, upper + "Plugin.coffee");
      this.project.templates.generate('GulpPluginClass', {
        name: upper,
        "super": v.uses
      }, destFile);
      plugin = require(destFile);
      results.push(this.add(upper, plugin));
    }
    return results;
  };

  return PluginsRegistry;

})(Collection);

module.exports = PluginsRegistry;
