var EventEmitter, Kohi, Phase,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

EventEmitter = require('events').EventEmitter;

Phase = require('./project/ScriptPhase');

Kohi = (function(superClass) {
  extend(Kohi, superClass);

  function Kohi(opts) {
    if (opts == null) {
      opts = {};
    }
    this.done = bind(this.done, this);
    this.execute = bind(this.execute, this);
    this.configure = bind(this.configure, this);
    this.initialize = bind(this.initialize, this);
    this.nextPhase = bind(this.nextPhase, this);
  }

  Kohi.prototype.nextPhase = function() {
    switch (this.phase) {
      case Phase.Initial:
        return this.initialize();
      case Phase.Initialization:
        return this.configure();
      case Phase.Configuration:
        return this.execute();
      case Phase.Execution:
        return this.done();
    }
  };

  Kohi.prototype.initialize = function() {
    this.phase = Phase.Initialization;
    this.initialized = true;
    return this.emit('phase', this.phase);
  };

  Kohi.prototype.configure = function() {
    if (!this.initialized) {
      this.initialize();
    }
    this.phase = Phase.Configuration;
    this.configured = true;
    return this.emit('phase', this.phase);
  };

  Kohi.prototype.execute = function() {
    if (!this.configured) {
      this.configure();
    }
    this.phase = Phase.Execution;
    return this.emit('phase', this.phase);
  };

  Kohi.prototype.done = function() {};

  return Kohi;

})(EventEmitter);

module.exports = Kohi;
