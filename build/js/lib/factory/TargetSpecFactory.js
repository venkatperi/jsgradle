var BaseFactory, TargetSpec, TargetSpecFactory, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./BaseFactory');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

TargetSpec = rek('TargetSpec');

TargetSpecFactory = (function(superClass) {
  extend(TargetSpecFactory, superClass);

  function TargetSpecFactory() {
    this.newInstance = bind(this.newInstance, this);
    return TargetSpecFactory.__super__.constructor.apply(this, arguments);
  }

  TargetSpecFactory.prototype.newInstance = function(builder, name, value, args) {
    log.v('newInstance');
    return new TargetSpec({
      dir: value
    });
  };

  return TargetSpecFactory;

})(BaseFactory);

module.exports = TargetSpecFactory;
