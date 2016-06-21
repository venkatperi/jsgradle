var BaseObject, Collection, Q, _, log, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

BaseObject = rek('BaseObject');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

prop = rek('prop');

Q = require('q');

Collection = (function(superClass) {
  extend(Collection, superClass);

  function Collection() {
    this.map = bind(this.map, this);
    this.forEachp = bind(this.forEachp, this);
    this.forEach = bind(this.forEach, this);
    this.some = bind(this.some, this);
    this.filter = bind(this.filter, this);
    this.matching = bind(this.matching, this);
    this["delete"] = bind(this["delete"], this);
    this.get = bind(this.get, this);
    this.has = bind(this.has, this);
    this.add = bind(this.add, this);
    this.setChild = bind(this.setChild, this);
    this._init = bind(this._init, this);
    return Collection.__super__.constructor.apply(this, arguments);
  }

  prop(Collection, 'size', {
    get: function() {
      return this.items.size;
    }
  });

  Collection._addProperties({
    optional: ['name', 'convertName', 'parent']
  });

  Collection.prototype._init = function(opts) {
    Collection.__super__._init.call(this, opts);
    this.values = [];
    this.items = new Map();
    return this.convertName != null ? this.convertName : this.convertName = function(x) {
      return x;
    };
  };

  Collection.prototype.setChild = function(child) {
    if (!(child != null ? child.name : void 0)) {
      throw new Error("Child does not have a 'name' field.");
    }
    return this.add(child.name, child);
  };

  Collection.prototype.add = function(name, item) {
    name = this.convertName(name);
    if (this.has(name)) {
      throw new Error("Item exists: " + name);
    }
    this.items.set(name, item);
    if (item.name == null) {
      item.name = name;
    }
    this.values.push(item);
    this.emit('add', name, item);
    return this;
  };

  Collection.prototype.has = function(name) {
    return this.items.has(this.convertName(name));
  };

  Collection.prototype.get = function(name) {
    var i, len, obj, p, path, ref;
    if (name == null) {
      return;
    }
    path = name.split('.');
    obj = this.items.get(path[0]);
    ref = path.slice(1);
    for (i = 0, len = ref.length; i < len; i++) {
      p = ref[i];
      obj = obj.get(p);
      if (obj == null) {
        return;
      }
    }
    return obj;
  };

  Collection.prototype["delete"] = function(name) {
    var idx, val;
    if (!this.items.has(name)) {
      throw new Error(name + " is not in collection");
    }
    val = this.items.get(name);
    idx = this.values.indexOf(val);
    this.items["delete"](this.convertName(name));
    return this.values.splice(idx, 1);
  };

  Collection.prototype.matching = function(f) {
    return _.filter(this.values, f);
  };

  Collection.prototype.filter = function(f) {
    return _.filter(this.values, f);
  };

  Collection.prototype.some = function(f) {
    return _.some(this.values, f);
  };

  Collection.prototype.forEach = function(f) {
    var ref;
    return (ref = this.items) != null ? ref.forEach(f) : void 0;
  };

  Collection.prototype.forEachp = function(f) {
    var res;
    res = Q();
    this.items.forEach(function(x) {
      return res = res.then(function() {
        return f(x);
      });
    });
    return res;
  };

  Collection.prototype.map = function(f) {
    return _.map(this.values, f);
  };

  return Collection;

})(BaseObject);

module.exports = Collection;
