_ = require 'lodash'
{EventEmitter} = require 'events'
Task = require './Task'
TaskFactory = require './TaskFactory'
Path = require './Path'
ScriptPhase = require './ScriptPhase'
p = require './util/prop'
TaskContainer = require './TaskContainer'
ExtensionContainer = require './ExtensionContainer'
TaskGraphExecutor = require './TaskGraphExecutor'

module.exports = class Project extends EventEmitter

  p @, 'path', get : -> @_path.fullPath

  p @, 'rootDir', get : -> @_rootDir

  p @, 'buildDir', get : -> @_buildDir

  p @, 'buildFile', get : -> @_buildFile

  p @, 'childProjects', get : ->

  p @, 'allProjects', get : ->

  p @, 'subProjects', get : ->

  p @, 'description',
    get : -> @_description
    set : ( v ) -> @_set '_description', v

  p @, 'version',
    get : -> @_version
    set : ( v ) -> @_set '_version', v

  p @, 'status',
    get : -> @_status
    set : ( v ) -> @_set '_status', v

  constructor : ( {@name, @parent, @projectDir, @script} = {} ) ->
    throw new Error "Project name must be defined" unless @name?
    @rootProject = parent?.rootProject or @

    @description = "project #{@name}"
    @version = "0.1.0"
    @_prop = {}
    @_taskContainer = new TaskContainer()
    @extensions = new ExtensionContainer()
    @extensions.add 'greeting', @_greeting

    if @parent
      @_path = new Path @parent.absoluteProjectPath name
      @depth = @parent.depth + 1
    else
      @depth = 0
      @_path = new Path [ @name ], true

    @script.on 'phase', @phase

  phase : ( p ) =>
    @_phase = p
    switch @_phase
      when ScriptPhase.Initialization
        return @initialize()
      when ScriptPhase.Configuration
        return @configure()
      when ScriptPhase.Execution
        return @execute()
      when ScriptPhase.Done
        @done()

  initialize : =>

  configure : =>
    for own name,t of @_taskContainer.taskInfo
      t.configure()

  execute : =>
    executor = new TaskGraphExecutor(@_taskContainer)
    nodes = (@_taskContainer.node t for t in @_defaultTasks)
    executor.add nodes
    executor.determineExecutionPlan()
    console.log _.map executor.executionQueue, ( x ) -> x.task.name
    for t in executor.executionQueue
      t.execute()

  defaultTasks : ( tasks... ) =>
    @_defaultTasks = tasks

  property : ( name, val ) ->
    old = @_prop[ name ]
    return prop if arguments.length is 1
    unless val is old
      @[ name ] = val
      @emit 'property', name, val, old
    @

  addTask : ( name, opts, configure ) =>
    opts ?= {}
    opts.name = name
    opts.project = @
    if configure?
      runWith = @script.context.runWith
      cfg = ( task ) -> -> runWith (-> configure(task)), task
    @_taskContainer.create opts, cfg

  compareTo : ( other ) =>
    diff = @depth - other.depth
    return diff unless diff is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  methodMissing : ( name, args... ) =>
    return unless @extensions.has name
    @script.context.runWith args[ 0 ], @extensions.get name
    true

  _set : ( name, val ) ->
    old = @[ name ]
    unless val is @[ name ]
      @[ name ] = val
      @emit 'change', name, val, old
    @

  toString : =>
    "project #{name}"

