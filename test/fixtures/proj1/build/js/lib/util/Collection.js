var Collection, EventEmitter, _,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

EventEmitter = require('events').EventEmitter;

Collection = (function(superClass) {
  extend(Collection, superClass);

  function Collection(arg) {
    this.convertName = (arg != null ? arg : {}).convertName;
    this.forEach = bind(this.forEach, this);
    this.matching = bind(this.matching, this);
    this["delete"] = bind(this["delete"], this);
    this.get = bind(this.get, this);
    this.has = bind(this.has, this);
    this.add = bind(this.add, this);
    this.items = new Map();
    if (this.convertName == null) {
      this.convertName = function(x) {
        return x;
      };
    }
  }

  Collection.prototype.add = function(name, item) {
    name = this.convertName(name);
    if (this.has(name)) {
      throw new Error("Item exists: " + name);
    }
    this.items.set(name, item);
    this.emit('add', item);
    return this;
  };

  Collection.prototype.has = function(name) {
    return this.items.has(this.convertName(name));
  };

  Collection.prototype.get = function(name) {
    return this.items.get(this.convertName(name));
  };

  Collection.prototype["delete"] = function(name) {
    return this.items["delete"](this.convertName(name));
  };

  Collection.prototype.matching = function(f) {
    return _.filter(this.items, f);
  };

  Collection.prototype.forEach = function(f) {
    return this.items.forEach(f);
  };

  return Collection;

})(EventEmitter);

module.exports = Collection;
