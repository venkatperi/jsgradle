throughGulp = require 'through-gulp'
{EventEmitter} = require 'events'
Q = require 'q'

_plugin = ( obj ) ->
  throughGulp ( f, e, _cb ) ->
    _that = this
    obj._onData f, e
    .then ( v ) ->
      _that.push v if v?
      _cb()
  , ( _cb ) ->
    _that = this
    obj._onDone()
    .then ( v ) ->
      _that.push null
      _cb()

class GulpThrough extends EventEmitter
  constructor : ( opts = {} )->
    @plugin = _plugin @

  _onData : ( file, enc ) =>
    @emit 'data', file
    Q.try =>
      @onData file, enc

  _onDone : () =>
    Q.try =>
      @onDone()
    .then =>
      @emit 'done'

  onData : ( file, enc ) => file

  onDone : () =>

module.exports = GulpThrough
    
  