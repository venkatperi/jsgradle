var SourceSpec, TargetSpec, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

SourceSpec = require('./SourceSpec');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

TargetSpec = (function() {
  function TargetSpec() {
    this.into = bind(this.into, this);
  }

  TargetSpec.prototype.into = function(dir) {
    return this.dest = dir;
  };

  return TargetSpec;

})();

module.exports = TargetSpec;
