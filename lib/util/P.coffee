Q = require 'q'

class P
  constructor : ->
    @defer = Q.defer()
    @promise = @defer.promise

  done : ( v ) => @defer.resolve v
  resolve : ( v ) => @defer.resolve v

  reject : ( v ) => @defer.reject v
  fail : ( v ) => @defer.reject v
  error : ( v ) => @defer.reject new Error v

module.exports = P
