var AbstractFactory, BaseFactory,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

AbstractFactory = require('coffee-dsl').AbstractFactory;

BaseFactory = (function(superClass) {
  extend(BaseFactory, superClass);

  function BaseFactory(arg) {
    this.script = (arg != null ? arg : {}).script;
    this.onNodeCompleted = bind(this.onNodeCompleted, this);
    this.setChild = bind(this.setChild, this);
    if (this.script == null) {
      throw new Error("Missing option: script");
    }
  }

  BaseFactory.prototype.setChild = function(builder, parent, child) {
    return typeof parent.setChild === "function" ? parent.setChild(child) : void 0;
  };

  BaseFactory.prototype.onNodeCompleted = function(builder, parent, node) {
    return typeof node.onCompleted === "function" ? node.onCompleted(parent) : void 0;
  };

  return BaseFactory;

})(AbstractFactory);

module.exports = BaseFactory;
