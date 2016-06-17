_ = require 'lodash'
rek = require 'rekuire'
{ensureOptions} = rek 'validate'
{EventEmitter} = require 'events'
prop = rek 'prop'
cache = require 'guava-cache'
deepCopy = require 'deep-copy'

class BaseObject extends EventEmitter

  @_addProperties : ( opts = {} ) ->
    @:: _properties ?= {}
    unless @:: hasOwnProperty "_properties"
      @:: _properties = deepCopy @:: _properties
    for own k,v of opts
      @:: _properties[ k ] ?= []
      @:: _properties[ k ].push x for x in opts[ k ] when @:: _properties[ k ].indexOf(x) < 0

  @_addProperties
    required : []
    optional : [ 'description' ]
    exported : [ 'description' ]
    exportedReadOnly : []
    exportedMethods : []

  prop @, '_cache', get : ->
    @__cache ?= cache()
    @__cache

  prop @, '_allProperties',
    get : -> @_cache.get '_allProperties',
      => _.concat @_properties.required, @_properties.optional

  prop @, '_allExported',
    get : -> @_cache.get '_allExported',
      => _.concat @_properties.exported, @_properties.exportedReadOnly

  constructor : ( opts = {} ) ->
    ensureOptions opts, @_properties.required if @_properties?.required
    _.extend @, _.pick opts, @_allProperties
    @init opts

  init : =>

  hasProperty : ( name ) =>
    name in @_allExported

  hasMethod : ( name ) =>
    name in @_properties.exportedMethods

  getProperty : ( name ) =>
    return @[ name ] if name in @_allExported

  setProperty : ( name, val ) =>
    return unless name in @_properties.exported
    @[ name ] = val

module.exports = BaseObject