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
SourceSetContainer = require '../task/SourceSetContainer'
TaskGraphExecutor = require './TaskGraphExecutor'
PluginsRegistry = require './PluginsRegistry'
log = require('../util/logger') 'Project'
out = require('../util/out')
SeqX = require '../util/SeqX'
Clock = require '../util/Clock'
FileResolver = require '../task/FileResolver'
util = require 'util'

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
    @rootProject = parent?.rootProject or @
    @description ?= "project #{@name}"
    @version ?= "0.1.0"
    @pluginsRegistry = new PluginsRegistry()
    @tasks = new TaskContainer()
    @extensions = new ExtensionContainer()
    @_sourceSets = new SourceSetContainer()
    @fileResolver = new FileResolver projectDir : @projectDir
    @plugins = {}
    @_prop = {}
    @methods = [ 'apply', 'defaultTasks' ]

    if @parent
      @_path = new Path @parent.absoluteProjectPath name
      @depth = @parent.depth + 1
    else
      @depth = 0
      @_path = new Path [ @name ], true

    #@extensions.on 'add', ( name ) =>
    #  @methods.push name

  hasProperty : ( name ) =>
    log.v 'hasProperty', name
    name in [ 'description', 'name', 'version' ]

  hasMethod : ( name ) =>
    log.v 'hasMethod', name
    return true if name in [ 'apply', 'defaultTasks' ]

  getProperty : ( name ) =>
    log.v 'getProperty', name
    return @[ name ] if name in [ 'description', 'name', 'version' ]

  setProperty : ( name, val ) =>
    log.v 'setProperty', "#{name}:", val
    @[ name ] = val

  invokeMethod : ( name, args ) =>
    log.v 'invokeMethod', name
    if @[ name ]?
      @[ name ].apply @, args
#else
#  @script.invokeMethod name, args

  initialize : =>
    unless @parent
      @totalTime = new Clock()
    log.v 'initialize'

  configure : =>
    clock = new Clock()
    log.v tag = "configuring #{@path}"
    @tasks.forEach ( t ) => @seq t.configure
    @_afterEvaluate()
    @seq -> log.v tag, 'done', clock.pretty

  execute : =>
    log.v tag = "executing #{@path}"
    clock = new Clock()
    executor = new TaskGraphExecutor(@tasks)
    @_defaultTasks ?= []
    nodes = (@tasks.get t for t in @_defaultTasks)
    executor.add nodes
    @taskQueue = queue = executor.determineExecutionPlan()
    log.v 'tasks:', _.map executor.executionQueue, ( x ) -> x.task.name

    queue.forEach ( t ) =>  @seq => @runp t.execute
    @seq =>
      log.v tag, 'done: ', clock.pretty

  report : =>
    errors = []
    @taskQueue?.forEach ( t ) =>
      errors.push name : t.name, errors : t.errors if t.errors?.length

    out.eol()
    if errors.length is 0
      out('BUILD SUCCESSFUL').eol()
    else
      num = errors.length
      ex = 'exception'
      ex += 's' if num > 1
      out.red("FAILURE: Build failed with #{num} #{ex}").eol()
      for e in errors
        out("> #{e.name}").eol()

  defaultTasks : ( tasks... ) =>
    log.v 'defaultTasks', tasks
    @_defaultTasks = tasks

  apply : ( opts ) =>
    log.v 'apply', util.inspect opts
    opts = opts[ 0 ] if Array.isArray opts
    if opts?.plugin
      name = opts.plugin
      unless @pluginsRegistry.has name
        throw new Error "No such plugin: #{name}"
      ctor = @pluginsRegistry.get name
      plugin = @plugins[ name ] = new ctor()
      plugin.apply @

  task : ( name, opts, f ) =>
    log.v 'task', name, opts
    opts ?= {}
    opts.name = name
    opts.project = @
    task = @tasks.create opts, f
    #@script.setDelegate f, task
    null

  sourceSets : ( f ) =>
    run = @script.context.runWith
    @_sourceSets.forEach ( s ) ->
      s.configure run, f

  compareTo : ( other ) =>
    diff = @depth - other.depth
    return diff unless diff is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  methodMissing : ( name, args... ) =>
    return unless @extensions.has name
    log.v 'configuring extension:', name
    @script.context.runWith args[ 0 ], @extensions.get name
    true

  callScriptMethod : ( delegate, fn, args... ) =>
    @script.callScriptMethod delegate, fn, args...

  runp : ( fn, args = [], ctx = [] ) =>
    p = new P()
    args.push p
    args.push @runp
    #list = [ (-> fn.apply null, args) ]

    list = list.concat ctx
    list.push p

    try
    #ret = @script.context.runWith.apply @script.context, list
      ret = @script.call.apply @script, list
      p.resolve ret unless p.asyncCalled
    catch err
      p.reject err
    p.promise

  _afterEvaluate : =>
    clock = new Clock()
    tag = "onAfterEvaluate #{@path}"
    @seq -> log.v tag
    @tasks.forEach ( t ) =>  @seq t.afterEvaluate
    @seq -> log.v tag, 'done:', clock.pretty

  _set : ( name, val ) ->
    old = @[ name ]
    unless val is @[ name ]
      @[ name ] = val
      @emit 'change', name, val, old
    @

  toString : =>
    "project #{name}"

