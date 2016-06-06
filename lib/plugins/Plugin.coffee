class GreetingPlugin
  constructor : ->

  apply : ( project ) =>
    @configured = true
    @project = project

module.exports = GreetingPlugin