Plugin = require './Plugin'
rek = require 'rekuire'
ProxyFactory = rek 'ProxyFactory'

class Greeting
  constructor : ( @name = 'noname' ) ->

  hasProperty : ( name ) =>
    name in [ 'name' ]

  setProperty : ( k, v ) =>
    @[ k ] = v

class GreetingPlugin extends Plugin
  constructor : ->

  doApply : =>
    @greeting = new Greeting()
    
    @register
      extensions :
        greeting : @greeting

    @createTask 'hello', null, ( t ) =>
      t.doFirst =>
        @project.println("hello #{@greeting.name}")

module.exports = GreetingPlugin