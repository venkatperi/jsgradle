var BaseFactory, OptionsFactory, configurable, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./BaseFactory');

rek = require('rekuire');

configurable = rek('configurable');

OptionsFactory = (function(superClass) {
  extend(OptionsFactory, superClass);

  function OptionsFactory() {
    this.newInstance = bind(this.newInstance, this);
    return OptionsFactory.__super__.constructor.apply(this, arguments);
  }

  OptionsFactory.prototype.newInstance = function(builder, name, value, args) {
    var obj;
    obj = configurable({}, this.script.project.callScriptMethod);
    obj.__factory = name;
    return obj;
  };

  return OptionsFactory;

})(BaseFactory);

module.exports = OptionsFactory;
