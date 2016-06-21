var Action, BaseObject, Q, _, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

Q = require('q');

prop = rek('prop');

BaseObject = rek('BaseObject');

Action = (function(superClass) {
  extend(Action, superClass);

  function Action() {
    this.doExec = bind(this.doExec, this);
    this.println = bind(this.println, this);
    this._init = bind(this._init, this);
    return Action.__super__.constructor.apply(this, arguments);
  }

  prop(Action, 'project', {
    get: function() {
      return this.task.project;
    }
  });

  prop(Action, 'isSandbox', {
    get: function() {
      var ref;
      return ((ref = this.f) != null ? ref.type : void 0) === 'function';
    }
  });

  Action._addProperties({
    required: ['task'],
    optional: ['f']
  });

  Action.prototype._init = function(opts) {
    return Action.__super__._init.call(this, opts);
  };

  Action.prototype.println = function(msg) {
    return this.project.println(msg);
  };

  Action.prototype.doExec = function() {
    var promise;
    if ((this.exec != null) && (this.execSync != null)) {
      throw new Error("Only one of 'exec' or 'execSync' may be defined");
    }
    if (this.exec != null) {
      promise = Q.Promise(this.exec);
    }
    if (this.execSync != null) {
      promise = Q(this.execSync());
    }
    if (this.f) {
      promise = Q(this.f());
    }
    if (promise) {
      return promise.fail(this.addError);
    }
    return new Error("Don't know how to execute action");
  };

  return Action;

})(BaseObject);

module.exports = Action;
