var GreetingPlugin, Plugin, log,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

log = require('../util/logger')('GreetingPlugin');

GreetingPlugin = (function(superClass) {
  extend(GreetingPlugin, superClass);

  function GreetingPlugin() {
    this.apply = bind(this.apply, this);
    log.v('ctor()');
    this.greeting = {
      name: 'noname'
    };
  }

  GreetingPlugin.prototype.apply = function(project) {
    if (this.configured) {
      return;
    }
    GreetingPlugin.__super__.apply.call(this, project);
    project.extensions.add('greeting', this.greeting);
    return project.task('hello', null, (function(_this) {
      return function(t) {
        log.v('configuring');
        t.doFirst(function() {
          return console.log("hello " + _this.greeting.name);
        });
        return log.v('done config');
      };
    })(this));
  };

  return GreetingPlugin;

})(Plugin);

module.exports = GreetingPlugin;
