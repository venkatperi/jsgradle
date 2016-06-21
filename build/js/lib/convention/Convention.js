var BaseObject, Configuration, Convention, _, log, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

BaseObject = rek('BaseObject');

prop = rek('prop');

Configuration = rek('Configuration');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

Convention = (function(superClass) {
  extend(Convention, superClass);

  function Convention() {
    this.createSourceSet = bind(this.createSourceSet, this);
    this.createConfiguration = bind(this.createConfiguration, this);
    this.getConfiguration = bind(this.getConfiguration, this);
    this.configurationExists = bind(this.configurationExists, this);
    this.getSourceSet = bind(this.getSourceSet, this);
    this.sourceSetExists = bind(this.sourceSetExists, this);
    this.apply = bind(this.apply, this);
    return Convention.__super__.constructor.apply(this, arguments);
  }

  Convention._addProperties({
    required: ['name']
  });

  Convention.prototype.apply = function(project) {
    if (this.initialized != null) {
      return;
    }
    this.initialized = true;
    this.project = project;
    if (typeof this.createConfigurations === "function") {
      this.createConfigurations();
    }
    return typeof this.createSourceSets === "function" ? this.createSourceSets() : void 0;
  };

  Convention.prototype.sourceSetExists = function(name) {
    return this.getSourceSet(name) != null;
  };

  Convention.prototype.getSourceSet = function(name) {
    return this.project.getSourceSets().get(name);
  };

  Convention.prototype.configurationExists = function(name) {
    return this.getConfiguration(name) != null;
  };

  Convention.prototype.getConfiguration = function(name) {
    return this.project.configurations.get(name);
  };

  Convention.prototype.createConfiguration = function(name) {
    return this.project.configurations.add(name, new Configuration({
      name: name
    }));
  };

  Convention.prototype.createSourceSet = function(path, klass, opts) {
    var _opts, item, name, parent, parentName, parts;
    if (opts == null) {
      opts = {};
    }
    if (path == null) {
      throw new Error("no path");
    }
    parts = path.split('.');
    if (!(parts.length > 0)) {
      throw new Error("empty path");
    }
    parentName = parts.slice(0, -1);
    name = parts[parts.length - 1];
    parent = (parentName.length === 0 ? this.project.getSourceSets() : this.getSourceSet(parentName.join('.')));
    if (parent == null) {
      throw new Error("bad path: " + path);
    }
    if (parent.get(name) != null) {
      throw new Error("item exists at path: " + path);
    }
    _opts = _.extend({}, opts);
    _.extend(_opts, {
      parent: parent,
      name: name
    });
    item = new klass(_opts);
    parent.add(name, item);
    return item;
  };

  return Convention;

})(BaseObject);

module.exports = Convention;
