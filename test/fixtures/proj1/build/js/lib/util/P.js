var P, Q, log,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Q = require('q');

log = require('./logger')('P');

P = (function() {
  function P() {
    this.async = bind(this.async, this);
    this.error = bind(this.error, this);
    this.fail = bind(this.fail, this);
    this.reject = bind(this.reject, this);
    this.resolve = bind(this.resolve, this);
    this.done = bind(this.done, this);
    this.defer = Q.defer();
    this.promise = this.defer.promise;
  }

  P.prototype.done = function(v) {
    return this.defer.resolve(v);
  };

  P.prototype.resolve = function(v) {
    return this.defer.resolve(v);
  };

  P.prototype.reject = function(v) {
    return this.defer.reject(v);
  };

  P.prototype.fail = function(v) {
    return this.defer.reject(v);
  };

  P.prototype.error = function(v) {
    return this.defer.reject(new Error(v));
  };

  P.prototype.async = function() {
    log.v('async');
    this.asyncCalled = true;
    return {
      resolve: this.defer.resolve,
      reject: this.defer.reject
    };
  };

  return P;

})();

module.exports = P;
