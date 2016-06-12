Plugin = require './Plugin'
rek = require 'rekuire'
out = rek 'out'
ProxyFactory = rek 'ProxyFactory'

class Greeting
  constructor : ( @name = 'noname' ) ->

  hasProperty : ( name ) =>
    name in [ 'name' ]

  setProperty : ( k, v ) =>
    @[ k ] = v

class GreetingPlugin extends Plugin
  constructor : ->
    @greeting = new Greeting()

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'greeting', @greeting

    project.task 'hello', null, ( t ) =>
      t.doFirst =>
        out.eolThen("hello #{@greeting.name}").eol()

module.exports = GreetingPlugin