{EventEmitter} = require 'events'
Phase = require './project/ScriptPhase'

class Kohi extends EventEmitter
  constructor : ( opts = {} ) ->

  nextPhase : =>
    switch @phase
      when Phase.Initial
        @initialize()
      when Phase.Initialization
        @configure()
      when Phase.Configuration
        @execute()
      when Phase.Execution
        @done()

  initialize : =>
    @phase = Phase.Initialization
    @initialized = true
    @emit 'phase', @phase

  configure : =>
    @initialize() unless @initialized
    @phase = Phase.Configuration
    @configured = true
    @emit 'phase', @phase

  execute : =>
    @configure() unless @configured
    @phase = Phase.Execution
    @emit 'phase', @phase

  done : =>

module.exports = Kohi