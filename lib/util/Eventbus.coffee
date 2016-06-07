{EventEmitter} = require 'events'

channels = new Map()

class Eventbus extends EventEmitter
  constructor : ( opts = {} ) ->

module.exports = ( channel = 'default', opt ) ->
  unless channels.has channel
    channels.set channel, new Eventbus opt

  channels.get channel