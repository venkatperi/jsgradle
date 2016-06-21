var Greeting, GreetingPlugin, Plugin, ProxyFactory, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

rek = require('rekuire');

ProxyFactory = rek('ProxyFactory');

Greeting = (function() {
  function Greeting(name1) {
    this.name = name1 != null ? name1 : 'noname';
    this.setProperty = bind(this.setProperty, this);
    this.hasProperty = bind(this.hasProperty, this);
  }

  Greeting.prototype.hasProperty = function(name) {
    return name === 'name';
  };

  Greeting.prototype.setProperty = function(k, v) {
    return this[k] = v;
  };

  return Greeting;

})();

GreetingPlugin = (function(superClass) {
  extend(GreetingPlugin, superClass);

  function GreetingPlugin() {
    this.doApply = bind(this.doApply, this);
    return GreetingPlugin.__super__.constructor.apply(this, arguments);
  }

  GreetingPlugin.prototype.doApply = function() {
    this.greeting = new Greeting();
    this.register({
      extensions: {
        greeting: this.greeting
      }
    });
    return this.createTask('hello', null, (function(_this) {
      return function(t) {
        return t.doFirst(function() {
          return _this.project.println("hello " + _this.greeting.name);
        });
      };
    })(this));
  };

  return GreetingPlugin;

})(Plugin);

module.exports = GreetingPlugin;
