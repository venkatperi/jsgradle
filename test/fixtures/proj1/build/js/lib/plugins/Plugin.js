var GreetingPlugin,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

GreetingPlugin = (function() {
  function GreetingPlugin() {
    this.apply = bind(this.apply, this);
  }

  GreetingPlugin.prototype.apply = function(project) {
    this.configured = true;
    return this.project = project;
  };

  return GreetingPlugin;

})();

module.exports = GreetingPlugin;
