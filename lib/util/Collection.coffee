_ = require 'lodash'
{EventEmitter} = require 'events'

class Collection extends EventEmitter

  constructor : ( {@convertName, @name} = {} ) ->
    @values = []
    @items = new Map()
    @convertName ?= ( x ) -> x

  add : ( name, item ) =>
    name = @convertName name
    throw new Error "Item exists: #{name}" if @has name
    @items.set name, item
    @values.push item
    @emit 'add', name, item
    @

  has : ( name ) => @items.has @convertName name

  get : ( name ) =>
    path = name.split '.'
    obj = @items.get path[ 0 ]
    for p in path[ 1.. ]
      obj = obj.get p
      return unless obj?
    obj

  delete : ( name ) =>
    throw new Error "#{name} is not in collection" unless @items.has name
    val = @items.get name
    idx = @values.indexOf val
    @items.delete @convertName name
    @values.splice idx, 1

  matching : ( f ) =>  _.filter @values, f

  filter : ( f ) =>  _.filter @values, f

  some : ( f ) =>  _.some @values, f

  forEach : ( f ) => @items.forEach f

  map : ( f ) => _.map @values, f

module.exports = Collection