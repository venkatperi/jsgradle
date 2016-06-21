var BaseObject, DependenciesExt, Dependency, _, log, parse, rek, semver,
  slice = [].slice,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

BaseObject = rek('BaseObject');

Dependency = rek('Dependency');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

semver = require('semver');

parse = function() {
  var a, d, deps;
  a = 1 <= arguments.length ? slice.call(arguments, 0) : [];
  if (!(a.length > 0)) {
    return [];
  }
  d = Dependency.create.apply(Dependency, a);
  if (d != null) {
    return [d];
  }
  deps = _.map(a, function(x) {
    return Dependency.create(x);
  });
  if (_.some(deps, function(x) {
    return !x;
  })) {
    throw new Error("Invalid dependencies: " + a);
  }
  return deps;
};

DependenciesExt = (function(superClass) {
  extend(DependenciesExt, superClass);

  function DependenciesExt() {
    this.onConfigurationAdded = bind(this.onConfigurationAdded, this);
    return DependenciesExt.__super__.constructor.apply(this, arguments);
  }

  DependenciesExt.prototype.onConfigurationAdded = function(name, configuration) {
    var base;
    this[name] = (function(_this) {
      return function() {
        var args, d, deps, i, len, results;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        deps = parse.apply(null, args);
        results = [];
        for (i = 0, len = deps.length; i < len; i++) {
          d = deps[i];
          results.push(configuration.dependencies.add(d.name, d));
        }
        return results;
      };
    })(this);
    if ((base = this._properties).exportedMethods == null) {
      base.exportedMethods = [];
    }
    return this._properties.exportedMethods.push(name);
  };

  return DependenciesExt;

})(BaseObject);

module.exports = DependenciesExt;
