Plugin = require './Plugin'
rek = require 'rekuire'
out = rek 'out'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
SingletonFactory = rek 'SingletonFactory'

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
    project.script.registerFactory 'greeting', new SingletonFactory(@greeting)

    project.task 'hello', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>
        log.v 'executing'
        out.eolThen("hello #{@greeting.name}").eol()
      log.v 'done config'

module.exports = GreetingPlugin