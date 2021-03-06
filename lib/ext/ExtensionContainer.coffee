{EventEmitter} = require 'events'

class ExtensionContainer extends EventEmitter
  constructor : () ->
    @_items = new Map()

  add : ( name, ext ) =>
    @_items.set name, ext
    @emit 'add', name, ext

  keys: => Array.from @_items.keys()
  
  has : ( name ) => @_items.has name
  
  get: (name) => @_items.get name

module.exports = ExtensionContainer