var SeqX, seqx,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

seqx = require('seqx');

SeqX = (function() {
  function SeqX() {
    this._seq = bind(this._seq, this);
  }

  SeqX.prototype._seq = function(task) {
    if (this._seqx == null) {
      this._seqx = seqx();
    }
    return this._done = this._seqx.add.apply(this._seqx, arguments).fail((function(_this) {
      return function(err) {
        return _this.emit('error', err);
      };
    })(this));
  };

  return SeqX;

})();

module.exports = SeqX;
