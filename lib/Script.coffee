CoffeeDsl = require 'coffee-dsl'
Phase = require './ScriptPhase'
Project = require './Project'
path = require 'path'
fs = require 'fs'
GreetingPlugin = require './plugins/GreetingPlugin'
PluginsRegistry = require './PluginsRegistry'

class Script extends CoffeeDsl
  constructor : ( {@scriptFile} = {} ) ->
    throw new Error "Missing option: scriptFile" unless @scriptFile
    super()
    @_ext = {}
    @pluginsRegistry = new PluginsRegistry()
    @plugins = {}
    #@plugins.greeting = new GreetingPlugin()
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
    @configurePlugins()
    @evaluate @contents
    @configured = true
    @emit 'phase', @phase

  execute : =>
    @configure() unless @configured
    @phase = Phase.Execution
    @emit 'phase', @phase

  done : =>

  configurePlugins : =>
    for own k,v of @plugins
      v.apply @project

  ext : ( f ) => f()

  apply : ( opts ) =>
    if opts?.plugin
      name = opts.plugin
      unless @pluginsRegistry.has name
        throw new Error "No such plugin: #{name}"
      ctor = @pluginsRegistry.get name
      plugin = @plugins[ name ] = new ctor()
      plugin.apply @project

  task : ( name, opts, f ) =>
    if Array.isArray name
      f = opts
      [name,opts] = name
    [f, opts] = [ opts ] unless f?
    #console.log "task: #{name}"
    @project.addTask name, opts, f

  methodMissing : ( name ) => ( args... ) =>
    #console.log "method missing: #{name}, #{JSON.stringify args}"
    val = @project.methodMissing name, args...
    return val if val?
    return [ name ] unless args.length
    args = args[ 0 ] if args.length is 1
    [ name, args ]

  propertyMissing : ( name ) ->
    #console.log "property missing: #{name}"
    name

module.exports = Script