util = require 'util'
_ = require 'lodash'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

configurable = ( obj, invoker ) ->

  wrap = ( value ) ->
    return value unless _.isObjectLike(value)
    configurable value, invoker

  handlers =
    get : ( target, name ) ->
      switch name
        when 'hasProperty' then ( x ) -> true
        when 'hasMethod' then ( x ) -> x?
        when 'getProperty' then ( x ) ->
          v = target[ x ]
          if !_.isObjectLike(v) then v else x
        when 'setProperty' then ( k, v ) ->
          target[ k ] = v
        when 'getMethod' then ( x ) ->
          ( fn ) ->
            if fn?.type is 'function' and invoker?
              target[x] ?= configurable {}, invoker
              invoker target[x], fn
        else
          target[ name ]

    set : ( target, name, value ) ->
      target[ name ] = wrap value

    #deleteProperty : ( target, name ) ->
    #  return unless target[ name ]?
    #  delete target[ name ]

    #enumerate: ->
    #  Reflect.ownKeys properties

    #ownKeys : (target)->
    #  keys = Reflect.ownKeys target
    #  keys.push 'length'
    #  keys
    #
    #has : ( target, name ) ->
    #  name in properties
    #
    #defineProperty : ( target, name, desc ) ->
    #  properties.setKey name, desc
    #  target
    #
    #getOwnPropertyDescriptor : ( target, name ) ->
    #  Object.getOwnPropertyDescriptor target, name

  if arguments.length is 1
    [invoker,obj] = [ obj ] if typeof obj is 'function'
  properties = {}
  properties[ k ] = wrap k, v for own k,v of obj
  new Proxy properties, handlers

module.exports = configurable
