var Action,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Action = (function() {
  function Action(f, isAsync) {
    this.f = f;
    this.isAsync = isAsync != null ? isAsync : true;
    this.exec = bind(this.exec, this);
  }

  Action.prototype.exec = function(p) {
    return this.f(p);
  };

  return Action;

})();

module.exports = Action;
