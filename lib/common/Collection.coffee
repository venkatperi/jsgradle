_ = require 'lodash'
rek = require 'rekuire'
BaseObject = rek 'BaseObject'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
prop = rek 'prop'
Q = require 'q'

class Collection extends BaseObject

  prop @, 'size', get : -> @items.size

  @_addProperties
    optional : [ 'name', 'convertName', 'parent' ]

  _init : ( opts ) =>
    super opts
    @values = []
    @items = new Map()
    @convertName ?= ( x ) -> x

  setChild : ( child ) =>
    throw new Error "Child does not have a 'name' field." unless child?.name
    @add child.name, child

  add : ( name, item ) =>
    name = @convertName name
    throw new Error "Item exists: #{name}" if @has name
    @items.set name, item
    item.name ?= name
    @values.push item
    @emit 'add', name, item
    @

  has : ( name ) => 
    @items.has @convertName name

  get : ( name ) =>
    return unless name?
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

  forEach : ( f ) => @items?.forEach f

  forEachp : ( f ) =>
    res = Q()
    @items.forEach ( x ) ->
      res = res.then -> f(x)
    res

  map : ( f ) => _.map @values, f

module.exports = Collection