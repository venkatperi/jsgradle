var BaseObject, EventEmitter, _, cache, deepCopy, ensureOptions, prop, rek, whatClass,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require('lodash');

rek = require('rekuire');

ensureOptions = rek('validate').ensureOptions;

EventEmitter = require('events').EventEmitter;

prop = rek('prop');

cache = require('guava-cache');

deepCopy = require('deep-copy');

whatClass = require('what-class');

BaseObject = (function(superClass) {
  extend(BaseObject, superClass);

  prop(BaseObject, 'failed', {
    get: function() {
      return this._checkFailed();
    }
  });

  prop(BaseObject, 'errorMessages', {
    get: function() {
      return this._cache.get('errorMessages', this._getErrorMessages);
    }
  });

  BaseObject._addProperties = function(opts) {
    var base, base1, k, results, v, x;
    if (opts == null) {
      opts = {};
    }
    if ((base = this.prototype)._properties == null) {
      base._properties = {};
    }
    if (!this.prototype.hasOwnProperty("_properties")) {
      this.prototype._properties = deepCopy(this.prototype._properties);
    }
    results = [];
    for (k in opts) {
      if (!hasProp.call(opts, k)) continue;
      v = opts[k];
      if ((base1 = this.prototype._properties)[k] == null) {
        base1[k] = [];
      }
      results.push((function() {
        var i, len, ref, results1;
        ref = opts[k];
        results1 = [];
        for (i = 0, len = ref.length; i < len; i++) {
          x = ref[i];
          if (this.prototype._properties[k].indexOf(x) < 0) {
            results1.push(this.prototype._properties[k].push(x));
          }
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  BaseObject._addProperties({
    required: [],
    optional: ['description', 'parent'],
    exported: ['description'],
    exportedReadOnly: [],
    exportedMethods: []
  });

  prop(BaseObject, 'root', {
    get: function() {
      var root;
      root = this;
      while ((root.parent != null)) {
        root = root.parent;
      }
      return root;
    }
  });

  prop(BaseObject, '_cache', {
    get: function() {
      if (this.__cache == null) {
        this.__cache = cache();
      }
      return this.__cache;
    }
  });

  prop(BaseObject, '_allProperties', {
    get: function() {
      var base, base1;
      if ((base = this._properties).required == null) {
        base.required = [];
      }
      if ((base1 = this._properties).optional == null) {
        base1.optional = [];
      }
      return _.concat(this._properties.required, this._properties.optional);
    }
  });

  prop(BaseObject, '_allExported', {
    get: function() {
      var base, base1;
      if ((base = this._properties).exported == null) {
        base.exported = [];
      }
      if ((base1 = this._properties).exportedReadOnly == null) {
        base1.exportedReadOnly = [];
      }
      return _.concat(this._properties.exported, this._properties.exportedReadOnly);
    }
  });

  function BaseObject(opts) {
    var ref;
    if (opts == null) {
      opts = {};
    }
    this.toString = bind(this.toString, this);
    this.setProperty = bind(this.setProperty, this);
    this.getProperty = bind(this.getProperty, this);
    this.hasMethod = bind(this.hasMethod, this);
    this.hasProperty = bind(this.hasProperty, this);
    this.addError = bind(this.addError, this);
    this._getErrorMessages = bind(this._getErrorMessages, this);
    this._checkFailed = bind(this._checkFailed, this);
    this._init = bind(this._init, this);
    if ((ref = this._properties) != null ? ref.required : void 0) {
      ensureOptions(opts, this._properties.required);
    }
    _.extend(this, _.pick(opts, this._allProperties));
    this.errors = [];
    this._init(opts);
  }

  BaseObject.prototype._init = function() {};

  BaseObject.prototype._checkFailed = function() {
    return this._failed;
  };

  BaseObject.prototype._getErrorMessages = function() {
    return this._cache.get('errorMessages', (function(_this) {
      return function() {
        return _.map(_this.errors, function(x) {
          return x.message;
        });
      };
    })(this));
  };

  BaseObject.prototype.addError = function(err) {
    this._failed = true;
    this.errors.push(err);
    this._cache["delete"]('errorMessages');
    return this.emit('error', err);
  };

  BaseObject.prototype.hasProperty = function(name) {
    var ref;
    return ((ref = this._allExported) != null ? ref.indexOf(name) : void 0) >= 0;
  };

  BaseObject.prototype.hasMethod = function(name) {
    return indexOf.call(this._properties.exportedMethods, name) >= 0;
  };

  BaseObject.prototype.getProperty = function(name) {
    if (this.hasProperty(name)) {
      return this[name];
    }
  };

  BaseObject.prototype.setProperty = function(name, val) {
    if (indexOf.call(this._properties.exported, name) < 0) {
      return;
    }
    return this[name] = val;
  };

  BaseObject.prototype.toString = function() {
    var inspect;
    inspect = function(k, v) {
      var ref;
      if ((k === 'parent' || k === 'items' || k === 'project' || k === 'task') || _.startsWith(k, '_event')) {
        return;
      }
      if ((ref = whatClass(v)) === 'Object' || ref === 'Array') {
        if (_.isEmpty(v)) {
          return;
        }
      }
      if (v.__type == null) {
        v.__type = v.constructor.name;
      }
      return v;
    };
    return JSON.stringify(this, inspect, 2);
  };

  return BaseObject;

})(EventEmitter);

module.exports = BaseObject;
