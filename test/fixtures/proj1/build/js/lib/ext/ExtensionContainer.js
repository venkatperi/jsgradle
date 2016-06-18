var EventEmitter, ExtensionContainer,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

EventEmitter = require('events').EventEmitter;

ExtensionContainer = (function(superClass) {
  extend(ExtensionContainer, superClass);

  function ExtensionContainer() {
    this.get = bind(this.get, this);
    this.has = bind(this.has, this);
    this.add = bind(this.add, this);
    this._items = new Map();
  }

  ExtensionContainer.prototype.add = function(name, ext) {
    this._items.set(name, ext);
    return this.emit('add', name, ext);
  };

  ExtensionContainer.prototype.has = function(name) {
    return this._items.has(name);
  };

  ExtensionContainer.prototype.get = function(name) {
    return this._items.get(name);
  };

  return ExtensionContainer;

})(EventEmitter);

module.exports = ExtensionContainer;
