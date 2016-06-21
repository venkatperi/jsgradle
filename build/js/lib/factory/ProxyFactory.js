var BaseFactory, ProxyFactory, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./BaseFactory');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

ProxyFactory = (function(superClass) {
  extend(ProxyFactory, superClass);

  function ProxyFactory(opts) {
    if (opts == null) {
      opts = {};
    }
    this.newInstance = bind(this.newInstance, this);
    this.obj = opts.target || (function() {
      throw new Error("Missing option: target");
    })();
    ProxyFactory.__super__.constructor.call(this, opts);
  }

  ProxyFactory.prototype.newInstance = function(builder, name) {
    log.v('newInstance', name);
    return this.obj;
  };

  return ProxyFactory;

})(BaseFactory);

module.exports = ProxyFactory;
