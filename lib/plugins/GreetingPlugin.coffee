Plugin = require './Plugin'

class GreetingPlugin extends Plugin
  constructor : ->
    @greeting =
      name : 'noname'

  apply : ( project ) =>
    super project
    project.extensions.add 'greeting', @greeting
    project.addTask 'hello', null, ( t ) =>
      t.doFirst =>
        console.log "hello #{@greeting.name}"

module.exports = GreetingPlugin