_ = require 'lodash'
rek = require 'rekuire'
{ensureOptions} = rek 'validate'
{EventEmitter} = require 'events'
prop = rek 'prop'
cache = require 'guava-cache'
deepCopy = require 'deep-copy'
traverse = require 'traverse'
json = rek 'json'
whatClass = require 'what-class'

class BaseObject extends EventEmitter

  prop @, 'failed', get : -> @_checkFailed()

  prop @, 'errorMessages', get : ->
    @_cache.get 'errorMessages', @_getErrorMessages

  @_addProperties : ( opts = {} ) ->
    @:: _properties ?= {}
    unless @:: hasOwnProperty "_properties"
      @:: _properties = deepCopy @:: _properties
    for own k,v of opts
      @:: _properties[ k ] ?= []
      @:: _properties[ k ].push x for x in opts[ k ] when @:: _properties[ k ].indexOf(x) < 0

  @_addProperties
    required : []
    optional : [ 'description', 'parent' ]
    exported : [ 'description' ]
    exportedReadOnly : []
    exportedMethods : []

  prop @, 'root',
    get : ->
      root = @
      while (root.parent?)
        root = root.parent
      root

  prop @, '_cache', get : ->
    @__cache ?= cache()
    @__cache

  prop @, '_allProperties',
    get : ->
      @_properties.required ?= []
      @_properties.optional ?= []
      _.concat @_properties.required, @_properties.optional

  prop @, '_allExported',
    get : ->
      @_properties.exported ?= []
      @_properties.exportedReadOnly ?= []
      _.concat @_properties.exported, @_properties.exportedReadOnly

  constructor : ( opts = {} ) ->
    ensureOptions opts, @_properties.required if @_properties?.required
    _.extend @, _.pick opts, @_allProperties
    @errors = []
    @init opts

  init : =>

  _checkFailed : => @_failed

  _getErrorMessages : =>
    @_cache.get 'errorMessages', => _.map @errors, ( x ) -> x.message

  addError : ( err ) =>
    @_failed = true
    @errors.push err
    @_cache.delete 'errorMessages'
    @emit 'error', err

  hasProperty : ( name ) =>
    @_allExported?.indexOf(name) >= 0

  hasMethod : ( name ) =>
    name in @_properties.exportedMethods

  getProperty : ( name ) =>
    return @[ name ] if @hasProperty name

  setProperty : ( name, val ) =>
    return unless name in @_properties.exported
    @[ name ] = val

  toString : =>
    inspect = ( k, v ) ->
      return if k in [ 'parent', 'items' ] or _.startsWith(k, '_event')
      if whatClass(v) in [ 'Object', 'Array' ]
        return if _.isEmpty v
      v.__type = v.constructor.name unless v.__type?
      v
    JSON.stringify @, inspect, 2

module.exports = BaseObject