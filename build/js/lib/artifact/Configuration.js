var BaseObject, Configuration, DependencySet, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

BaseObject = rek('BaseObject');

DependencySet = rek('DependencySet');

Configuration = (function(superClass) {
  extend(Configuration, superClass);

  function Configuration() {
    this._init = bind(this._init, this);
    return Configuration.__super__.constructor.apply(this, arguments);
  }

  Configuration._addProperties({
    required: ['name']
  });

  Configuration.prototype._init = function(opts) {
    Configuration.__super__._init.call(this, opts);
    return this.dependencies = new DependencySet({
      parent: this,
      name: this.name
    });
  };

  return Configuration;

})(BaseObject);

module.exports = Configuration;
