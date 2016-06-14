rek = require 'rekuire'
Q = require 'q'
_ = require 'lodash'
{multi} = require 'heterarchy'
{EventEmitter} = require 'events'

{ensureOptions} = rek 'validate'
Clock = rek 'Clock'
ExtensionContainer = rek 'lib/ext/ExtensionContainer'
FileResolver = rek 'FileResolver'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
out = rek 'lib/util/out'
Path = require './Path'
PluginContainer = require './PluginContainer'
PluginsRegistry = require './PluginsRegistry'
prop = rek 'lib/util/prop'
ProxyFactory = rek 'ProxyFactory'
ScriptPhase = require './ScriptPhase'
SeqX = rek 'SeqX'
SourceSetContainer = rek 'lib/task/SourceSetContainer'
TaskContainer = rek 'lib/task/TaskContainer'
TaskFactory = rek 'lib/task/TaskFactory'
TaskGraphExecutor = require './TaskGraphExecutor'

class Project extends multi EventEmitter, SeqX

  prop @, 'pkg', get : -> @extensions.get 'pkg'
  
  prop @, 'originalPkg', get : -> @extensions.get '__pkg'

  prop @, 'path', get : -> @_path.fullPath

  prop @, 'continueOnError', get : -> @script.continueOnError

  prop @, 'sourceSets', get : -> @extensions.get 'sourceSets'

  prop @, 'rootDir', get : -> @_rootDir

  prop @, 'buildDir', get : -> @_buildDir

  prop @, 'buildFile', get : -> @_buildFile

  prop @, 'childProjects', get : ->

  prop @, 'allProjects', get : ->

  prop @, 'subProjects', get : ->

  prop @, 'failed', get : -> @tasks.some ( x ) -> x.task.failed

  prop @, 'failedTasks', get : -> @tasks.filter ( x ) -> x.task.failed

  prop @, 'messages', get : ->
    _.flatten(_.map @failedTasks, ( x ) -> x.messages)

  prop @, 'description',
    get : -> @_description
    set : ( v ) ->
      @_set '_description', v
      @pkg?.description = v

  prop @, 'version',
    get : -> @_version
    set : ( v ) ->
      @_set '_version', v
      @pkg?.version = v

  prop @, 'status',
    get : -> @_status
    set : ( v ) -> @_set '_status', v

  constructor : ( {@name, @parent, @projectDir, @script} = {} ) ->
    ensureOptions @, 'name'
    @rootProject = parent?.rootProject or @
    @_defaultTasks = []
    @pluginsRegistry = new PluginsRegistry()
    @tasks = new TaskContainer()
    @extensions = new ExtensionContainer()
    @fileResolver = new FileResolver projectDir : @projectDir
    @plugins = new PluginContainer()
    @methods = [ 'apply', 'defaultTasks' ]
    @extensions.on 'add', ( name, ext ) =>
      return if _.startsWith name, '__'
      log.v 'adding ext', name
      @registerProxyFactory ext, name

    @description ?= "project #{@name}"
    @version ?= "0.1.0"
    if @parent
      @_path = new Path @parent.absoluteProjectPath name
      @depth = @parent.depth + 1
    else
      @depth = 0
      @_path = new Path [ @name ], true

  registerProxyFactory : ( target, name ) =>
    @script.registerFactory name,
      new ProxyFactory target : target, script : @script

  onCompleted : =>
    @emit 'afterEvaluate'

  hasProperty : ( name ) =>
    log.v 'hasProperty', name
    name in [ 'description', 'name', 'version' ]

  hasMethod : ( name ) =>
    log.v 'hasMethod', name
    return true if name in [ 'apply', 'defaultTasks', 'println' ]

  getProperty : ( name ) =>
    log.v 'getProperty', name
    return @[ name ] if name in [ 'description', 'name', 'version' ]

  setProperty : ( name, val ) =>
    log.v 'setProperty', "#{name}:", val
    @[ name ] = val

  println : ( args... ) ->
    out.eolThen('').white(args...).eol()

  initialize : =>
    log.v 'initialize'

  execute : =>
    log.v tag = "executing #{@path}"
    clock = new Clock()
    executor = new TaskGraphExecutor(@tasks)
    tasks = @_tasksToExecute or @_defaultTasks
    nodes = (@tasks.get t for t in _.flatten tasks)
    for n in nodes
      n.task.enable()
    executor.add nodes
    @taskQueue = queue = executor.determineExecutionPlan()
    for t in queue
      t.task.onAfterEvaluate()

    log.i 'tasks:', _.map executor.executionQueue, ( x ) -> x.task.name

    queue.forEach ( t ) =>  @seq t.execute
    @seq =>
      log.v tag, clock.pretty

  report : =>
    errors = []
    @taskQueue?.forEach ( t ) =>
      errors.push name : t.name, errors : t.errors if t.errors?.length

    out.eolThen('').eol()
    if !@failed
      out.white('BUILD SUCCESSFUL').eol()
    else
      msgs = Array.from @messages
      num = msgs.length
      ex = 'error'
      ex += 's' if msgs.length > 1
      out.red("FAILURE: Build failed with #{num} #{ex}.
        See task for details.").eol()
      for t in @failedTasks
        out('> ' + t.task.name).eol()

  defaultTasks : ( tasks... ) =>
    @_defaultTasks.push t for t in tasks

  apply : ( opts ) =>
    opts = opts[ 0 ] if Array.isArray opts
    if opts?.plugin
      name = opts.plugin
      return if @plugins[ name ]?
      unless @pluginsRegistry.has name
        throw new Error "No such plugin: #{name}"
      ctor = @pluginsRegistry.get name
      plugin = @plugins[ name ] = new ctor()
      plugin.apply @
      undefined

  task : ( name, opts, f ) =>
    log.v 'task', name, opts
    opts ?= {}
    opts.name = name
    opts.project = @
    task = @tasks.create opts
    f(task) if f?
    null

  compareTo : ( other ) =>
    diff = @depth - other.depth
    return diff unless diff is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  callScriptMethod : ( delegate, fn, args... ) =>
    @script.callScriptMethod delegate, fn, args...

  execTaskAction : ( task, action ) =>
    defer = Q.defer()
    try
      if action.isSandbox
        defer.resolve(@callScriptMethod task, action.f)
      else
        defer.resolve action.doExec()
    catch err
      defer.reject err
    defer.promise

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

module.exports = Project
