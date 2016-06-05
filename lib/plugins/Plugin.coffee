class GreetingPlugin
  constructor : ->

  apply : ( project ) =>
    @project = project

module.exports = GreetingPlugin