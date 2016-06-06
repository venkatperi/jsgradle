Plugin = require './Plugin'

class GreetingPlugin extends Plugin
  constructor : ->
    @greeting =
      name : 'noname'

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'greeting', @greeting
    
    project.task 'hello', null, ( t ) =>
      t.doFirst (p) =>
        console.log "hello #{@greeting.name}"
        p.resolve()

module.exports = GreetingPlugin