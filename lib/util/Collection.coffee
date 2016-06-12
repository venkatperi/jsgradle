_ = require 'lodash'
{EventEmitter} = require 'events'

class Collection extends EventEmitter

  constructor : ( {@convertName} = {} ) ->
    @items = new Map()
    @convertName ?= ( x ) -> x

  add : ( name, item ) =>
    name = @convertName name
    throw new Error "Item exists: #{name}" if @has name
    @items.set name, item
    @emit 'add', name, item
    @

  has : ( name ) => @items.has @convertName name

  get : ( name ) => @items.get @convertName name

  delete : ( name ) => @items.delete @convertName name

  matching : ( f ) =>  _.filter @items, f

  forEach : ( f ) => @items.forEach f

  map : ( f ) =>
    ret = []
    @items.forEach ( x ) -> ret.push f x
    ret

module.exports = Collection