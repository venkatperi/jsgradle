var EventEmitter, GulpThrough, Q, _plugin, throughGulp,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

throughGulp = require('through-gulp');

EventEmitter = require('events').EventEmitter;

Q = require('q');

_plugin = function(obj) {
  return throughGulp(function(f, e, _cb) {
    var _that;
    _that = this;
    return obj._onData(f, e).then(function(v) {
      if (v != null) {
        _that.push(v);
      }
      return _cb();
    });
  }, function(_cb) {
    var _that;
    _that = this;
    return obj._onDone().then(function(v) {
      _that.push(null);
      return _cb();
    });
  });
};

GulpThrough = (function(superClass) {
  extend(GulpThrough, superClass);

  function GulpThrough(opts) {
    if (opts == null) {
      opts = {};
    }
    this.onDone = bind(this.onDone, this);
    this.onData = bind(this.onData, this);
    this._onDone = bind(this._onDone, this);
    this._onData = bind(this._onData, this);
    this.plugin = _plugin(this);
  }

  GulpThrough.prototype._onData = function(file, enc) {
    this.emit('data', file);
    return Q["try"]((function(_this) {
      return function() {
        return _this.onData(file, enc);
      };
    })(this));
  };

  GulpThrough.prototype._onDone = function() {
    return Q["try"]((function(_this) {
      return function() {
        return _this.onDone();
      };
    })(this)).then((function(_this) {
      return function() {
        return _this.emit('done');
      };
    })(this));
  };

  GulpThrough.prototype.onData = function(file, enc) {
    return file;
  };

  GulpThrough.prototype.onDone = function() {};

  return GulpThrough;

})(EventEmitter);

module.exports = GulpThrough;
