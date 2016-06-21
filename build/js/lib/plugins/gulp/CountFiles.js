var CountFiles, GulpThrough, Q, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Q = require('q');

rek = require('rekuire');

GulpThrough = rek('GulpThrough');

CountFiles = (function(superClass) {
  extend(CountFiles, superClass);

  function CountFiles(opts) {
    this.onDone = bind(this.onDone, this);
    this.onData = bind(this.onData, this);
    CountFiles.__super__.constructor.call(this, opts);
    this.count = 0;
  }

  CountFiles.prototype.onData = function(f, e) {
    this.count++;
    return CountFiles.__super__.onData.call(this, f, e);
  };

  CountFiles.prototype.onDone = function() {
    this.emit('count', this.count);
    return CountFiles.__super__.onDone.call(this);
  };

  return CountFiles;

})(GulpThrough);

module.exports = CountFiles;
