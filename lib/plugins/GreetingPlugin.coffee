Plugin = require './Plugin'
log = require('../util/logger') 'GreetingPlugin'
out = require('../util/out')

class Extensible

  methodMissing : ( name ) => ( args... ) =>
    console.log 123
    log.i 'methodMissing', name

class GreetingPlugin extends Plugin
  constructor : ->
    log.v 'ctor()'
    @greeting = new Extensible()
    @greeting.name = 'noname'

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'greeting', @greeting

    project.task 'hello', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>
        log.v 'executing'
        out.eolThen("hello #{@greeting.name}").eol()
      log.v 'done config'

module.exports = GreetingPlugin