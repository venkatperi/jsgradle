Q = require 'q'
log = require('./logger') 'P'

class P
  constructor : ->
    @defer = Q.defer()
    @promise = @defer.promise

  done : ( v ) => @defer.resolve v
  resolve : ( v ) => @defer.resolve v

  reject : ( v ) => @defer.reject v
  fail : ( v ) => @defer.reject v
  error : ( v ) => @defer.reject new Error v

  async : =>
    log.v 'async'
    @asyncCalled = true
    resolve : @defer.resolve
    reject : @defer.reject

module.exports = P
