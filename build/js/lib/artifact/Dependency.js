var BaseObject, Dependency, _, allTrue, rek, semver,
  slice = [].slice,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

BaseObject = rek('BaseObject');

semver = require('semver');

allTrue = function() {
  var args;
  args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
  return !_.some(args, function(x) {
    return x === false;
  });
};

Dependency = (function(superClass) {
  extend(Dependency, superClass);

  function Dependency() {
    this.toString = bind(this.toString, this);
    return Dependency.__super__.constructor.apply(this, arguments);
  }

  Dependency._addProperties({
    required: ['name', 'version'],
    optional: ['context', 'group']
  });

  Dependency.prototype.toString = function() {
    return this.name + ":" + this.version;
  };

  Dependency.valid = function() {
    var args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return allTrue(args.length === 2, _.isString(args[0], _.isString(args[1], args[0].indexOf(':') < 0, semver.valid(args[1]))));
  };

  Dependency.create = function() {
    var a, args;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    if (args.length === 0) {
      return;
    }
    if (this.valid.apply(this, args)) {
      return new Dependency({
        name: args[0],
        version: args[1]
      });
    }
    a = args[0];
    if (!(a.indexOf(':') > 0)) {
      return;
    }
    return Dependency.create.apply(Dependency, a.split(':'));
  };

  return Dependency;

})(BaseObject);

module.exports = Dependency;
