CoffeeDsl = require 'coffee-dsl'
Phase = require './ScriptPhase'
Project = require './Project'
path = require 'path'
fs = require 'fs'

class Script extends CoffeeDsl
  constructor : ( {@scriptFile} = {} ) ->
    console.log @scriptFile
    throw new Error "Missing option: scriptFile" unless @scriptFile
    super()
    @_ext = {}
    @context.push @_ext
    @phase = Phase.Initial
    @loadScript()

  loadScript : =>
    @contents = fs.readFileSync @scriptFile, 'utf8'

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
    parts = path.parse @scriptFile
    @project = new Project
      script : @
      name : parts.name,
      projectDir : parts.dir,
    @context.push @project
    @initialized = true
    @emit 'phase', @phase

  configure : =>
    @initialize() unless @initialized
    @phase = Phase.Configuration
    @evaluate @contents
    @configured = true
    @emit 'phase', @phase

  execute : =>
    @configure() unless @configured
    @phase = Phase.Execution
    @emit 'phase', @phase

  done : =>

  ext : ( f ) => f()


  task : ( name, opts, f ) =>
    if Array.isArray name
      f = opts
      [name,opts] = name
    [f, opts] = [ opts ] unless f?
    #console.log "task: #{name}"
    @project.addTask name, opts, f

  methodMissing : ( name ) => ( args... ) =>
    #console.log "method missing: #{name}, #{JSON.stringify args}"
    return [ name ] unless args.length
    args = args[ 0 ] if args.length is 1
    [ name, args ]

  propertyMissing : ( name ) ->
    #console.log "property missing: #{name}"
    name

module.exports = Script