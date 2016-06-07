Plugin = require './Plugin'
log = require('../util/logger') 'GreetingPlugin'

class GreetingPlugin extends Plugin
  constructor : ->
    log.v 'ctor()'
    @greeting =
      name : 'noname'

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'greeting', @greeting

    project.task 'hello', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>
        console.log "hello #{@greeting.name}"
      log.v 'done config'

module.exports = GreetingPlugin