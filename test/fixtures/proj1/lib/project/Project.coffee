_ = require 'lodash'
{multi} = require 'heterarchy'
{EventEmitter} = require 'events'
TaskFactory = require '../task/TaskFactory'
Path = require './Path'
ScriptPhase = require './ScriptPhase'
P = require '../util/P'
prop = require '../util/prop'
TaskContainer = require '../task/TaskContainer'
ExtensionContainer = require '../ext/ExtensionContainer'
TaskGraphExecutor = require './TaskGraphExecutor'
PluginsRegistry = require './PluginsRegistry'
log = require('../util/logger') 'Project'
SeqX = require '../util/SeqX'
Clock = require '../util/Clock'

module.exports = class Project extends multi EventEmitter, SeqX

  prop @, 'path', get : -> @_path.fullPath

  prop @, 'rootDir', get : -> @_rootDir

  prop @, 'buildDir', get : -> @_buildDir

  prop @, 'buildFile', get : -> @_buildFile

  prop @, 'childProjects', get : ->

  prop @, 'allProjects', get : ->

  prop @, 'subProjects', get : ->

  prop @, 'description',
    get : -> @_description
    set : ( v ) -> @_set '_description', v

  prop @, 'version',
    get : -> @_version
    set : ( v ) -> @_set '_version', v

  prop @, 'status',
    get : -> @_status
    set : ( v ) -> @_set '_status', v

  constructor : ( {@name, @parent, @projectDir, @script} = {} ) ->
    throw new Error "Project name must be defined" unless @name?
    log.v 'ctor()', @name

    @rootProject = parent?.rootProject or @
    @description ?= "project #{@name}"
    @version ?= "0.1.0"
    @pluginsRegistry = new PluginsRegistry()
    @tasks = new TaskContainer()
    @extensions = new ExtensionContainer()
    @plugins = {}
    @_prop = {}

    if @parent
      @_path = new Path @parent.absoluteProjectPath name
      @depth = @parent.depth + 1
    else
      @depth = 0
      @_path = new Path [ @name ], true

  initialize : =>
    log.v 'initialize'

  configure : =>
    clock = new Clock()
    tag = "configuring #{@path}"
    log.v tag
    @tasks.forEach ( t ) => @_seq => @runp t.configure
    @onAfterEvaluate()
    @_seq =>
      log.v tag, 'done', clock.pretty

  execute : =>
    tag = "executing #{@path}"
    log.v tag
    clock = new Clock()
    executor = new TaskGraphExecutor(@tasks)
    nodes = (@tasks.get t for t in @_defaultTasks)
    executor.add nodes
    executor.determineExecutionPlan()
    log.i 'tasks:', _.map executor.executionQueue, ( x ) -> x.task.name
    executor.executionQueue.forEach ( t ) =>
      @_seq t.execute
    @_seq => log.v tag, 'done: ', clock.pretty

  defaultTasks : ( tasks... ) =>
    @_defaultTasks = tasks

  property : ( name, val ) ->
    old = @_prop[ name ]
    return prop if arguments.length is 1
    unless val is old
      @[ name ] = val
      @emit 'property', name, val, old
    @

  apply : ( opts ) =>
    if opts?.plugin
      name = opts.plugin
      unless @pluginsRegistry.has name
        throw new Error "No such plugin: #{name}"
      ctor = @pluginsRegistry.get name
      plugin = @plugins[ name ] = new ctor()
      plugin.apply @

  task : ( name, opts, f ) =>
    if Array.isArray name
      f = opts
      [name,opts] = name
    [f, opts] = [ opts ] unless f?
    opts ?= {}
    opts.name = name
    opts.project = @
    opts.runWith = runWith = @script.context.runWith
    if f?
      cfg = ( task ) -> -> runWith (-> f(task)), task
    @tasks.create opts, f

  compareTo : ( other ) =>
    diff = @depth - other.depth
    return diff unless diff is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  methodMissing : ( name, args... ) =>
    return unless @extensions.has name
    log.v 'methodMissing:', name
    @script.context.runWith args[ 0 ], @extensions.get name
    true

  runp : ( fn, args = [], ctx = [] ) =>
    p = new P()
    args.push p
    run = @script.context.runWith
    try
      list = [ (-> fn.apply null, args) ]
      list = list.concat ctx
      list.push p
      ret = run.apply @script.context, list
      p.resolve ret unless p.asyncCalled
    catch err
      p.reject err
    p.promise

  onAfterEvaluate : =>
    clock = new Clock()
    tag = "onAfterEvaluate #{@path}"
    log.v tag
    @tasks.forEach ( t ) => @_seq t.onAfterEvaluate
    @_seq => log.v tag, 'done:', clock.pretty

  _set : ( name, val ) ->
    old = @[ name ]
    unless val is @[ name ]
      @[ name ] = val
      @emit 'change', name, val, old
    @

  toString : =>
    "project #{name}"

