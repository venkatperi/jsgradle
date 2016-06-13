_ = require 'lodash'
{EventEmitter} = require 'events'


class Collection extends EventEmitter

  constructor : ( {@convertName, @name} = {} ) ->
    @items = new Map()
    @convertName ?= ( x ) -> x

  add : ( name, item ) =>
    name = @convertName name
    throw new Error "Item exists: #{name}" if @has name
    @items.set name, item
    @emit 'add', name, item
    @

  has : ( name ) => @items.has @convertName name

  get : ( name ) =>
    path = name.split '.'
    obj = @items.get path[0]
    for p in path[1..]
      obj = obj.get p
      return unless obj?
    obj

  delete : ( name ) => @items.delete @convertName name

  matching : ( f ) =>  _.filter @items, f

  forEach : ( f ) => @items.forEach f

  map : ( f ) =>
    ret = []
    @items.forEach ( x ) -> ret.push f x
    ret

module.exports = Collection