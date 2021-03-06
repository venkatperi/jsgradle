path = require 'path'
rek = require 'rekuire'
Q = require 'q'
_ = require 'lodash'
BaseObject = rek 'BaseObject'
Clock = rek 'Clock'
ExtensionContainer = rek 'lib/ext/ExtensionContainer'
FileResolver = rek 'FileResolver'
out = rek 'lib/util/out'
Path = require './../common/Path'
PluginContainer = require './../plugins/PluginContainer'
ConventionContainer = rek 'ConventionContainer'
ConfigurationContainer = rek 'ConfigurationContainer'
PluginsRegistry = require './../plugins/PluginsRegistry'
prop = rek 'lib/util/prop'
ProxyFactory = rek 'ProxyFactory'
ScriptPhase = require './ScriptPhase'
SourceSetContainer = rek 'lib/task/SourceSetContainer'
TaskContainer = rek 'lib/task/TaskContainer'
TaskFactory = rek 'lib/task/TaskFactory'
TaskGraphExecutor = require './TaskGraphExecutor'
DependenciesExt = rek 'DependenciesExt'
Dependency = rek 'Dependency'
conf = rek 'conf'
Templates = require '../templates'
configurable = rek 'configurable'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
qflow = rek 'qflow'

class Project extends BaseObject

  prop @, 'pkg', get : -> @extensions.get 'pkg'

  prop @, 'originalPkg', get : -> @extensions.get '__pkg'

  prop @, 'path', get : -> @_path.fullPath

  prop @, 'continueOnError', get : -> @script.continueOnError

  prop @, 'cacheDir', get : ->
    @_cache.get 'cacheDir',
      => @fileResolver.file conf.get('project:cache:cacheDir')

  prop @, 'rootDir', get : -> @_rootDir

  prop @, 'buildDir', get : ->
    @_cache.get 'buildDir',
      => path.join @projectDir, conf.get 'project:build:buildDir', 'build'

  prop @, 'genDir', get : ->
    @_cache.get 'genDir',
      => @file(conf.get 'project:build:genDir', 'gen')
    

  prop @, 'buildFile', get : -> @_buildFile

  prop @, 'childProjects', get : ->

  prop @, 'allProjects', get : ->

  prop @, 'subProjects', get : ->

  prop @, 'failed', get : -> @tasks.some ( x ) -> x.task.failed

  prop @, 'taskQueueNames', get : -> _.map @taskQueue, ( x ) =>
    if @isMultiProject then x.task.path else x.task.displayName

  prop @, 'failedTasks', get : -> @tasks.filter ( x ) -> x.task.failed

  prop @, 'messages',
    get : -> _.flatten(_.map @failedTasks, ( x ) -> x.messages)

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

  @_addProperties
    required : [ 'name', 'projectDir', 'script' ]
    optional : [ 'parent' ]
    exported : [ 'description', 'name', 'version' ]
    exportedReadOnly : []
    exportedMethods : [ 'apply', 'defaultTasks', 'println' ]

  _init : =>
    @isMultiProject = false
    @rootProject = @parent?.rootProject or @
    @_defaultTasks = conf.get 'project:build:defaultTasks', []
    @templates = new Templates()
    @fileResolver = new FileResolver projectDir : @projectDir
    @pluginsRegistry = new PluginsRegistry project : @
    @tasks = new TaskContainer()
    @conventions = new ConventionContainer()
    @configurations = new ConfigurationContainer()
    @extensions = new ExtensionContainer()
    @plugins = new PluginContainer
    @templates.on 'error', ( err ) =>
      console.log err
      @addError err

    @extensions.on 'add', ( name, ext ) =>
      return if _.startsWith name, '__'
      @registerProxyFactory ext, name

    @conventions.on 'add', ( name, obj ) => obj.apply @

    @extensions.add 'dependencies', new DependenciesExt()

    @configurations.on 'add', ( name, cfg ) =>
      @extensions.get('dependencies').onConfigurationAdded name, cfg

    @description ?= "project #{@name}"
    @version ?= conf.get 'project:build:version'

    if @parent
      @_path = new Path @parent.absoluteProjectPath name
      @depth = @parent.depth + 1
    else
      @depth = 0
      @_path = new Path [ @name ], true

    for p in conf.get('project:startup:plugins') or []
      @apply plugin : p

  _getErrorMessages : =>
    _.flatten(_.map @failedTasks, ( x ) -> x.messages)

  registerProxyFactory : ( target, name ) =>
    @script.registerFactory name,
      new ProxyFactory target : target, script : @script

  println : ( args... ) ->
    out.eolThen('').white(args...).eol()

  getSourceSets : =>
    @extensions.get 'sourceSets'

  file : ( name ) =>
    @fileResolver.file name

  initialize : =>

  afterEvaluate : =>
    @emit 'project:afterEvaluate:start', @
    numTasks = @tasks.size
    afterSize = 0
    qflow.until =>
      numTasks = @tasks.size
      executor = new TaskGraphExecutor(@tasks)
      tasks = @_tasksToExecute or @_defaultTasks
      nodes = (@tasks.get t for t in _.flatten tasks)
      n.task.enable() for n in nodes
      executor.add nodes

      @taskQueue = executor.determineExecutionPlan()

      qflow.each @taskQueue, ( t ) -> t.afterEvaluate()
      .then =>
        afterSize = @tasks.size
        numTasks is afterSize

    .finally =>
      @emit 'project:afterEvaluate:end', @

  execute : =>
    return if @failed
    @emit 'project:execute:start', @
    qflow.each @taskQueue, ( t ) -> t.execute()
    .finally =>
      @emit 'project:execute:end', @

  configure : =>
    @emit 'project:configure:start', @
    @tasks.forEachp ( t ) -> t.configure()
    .finally =>
      @emit 'project:configure:end', @

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
        out('> ' + t.task.displayName).eol()

  defaultTasks : ( tasks... ) =>
    @_defaultTasks.push t for t in tasks when t?

  apply : ( opts ) =>
    opts = opts[ 0 ] if Array.isArray opts
    if opts?.plugin
      name = opts.plugin
      return if @plugins[ name ]?
      unless @pluginsRegistry.has name
        throw new Error "No such plugin: #{name}"
      ctor = @pluginsRegistry.get name
      plugin = @plugins[ name ] = new ctor name : name
      plugin.apply @
      undefined

  task : ( name, opts, f ) =>
    opts ?= {}
    opts.name = name
    opts.project = @
    task = @tasks.create opts
    @script.listenTo task
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

  _set : ( name, val ) ->
    old = @[ name ]
    unless val is @[ name ]
      @[ name ] = val
      @emit 'change', name, val, old
    @

  toString : => "project #{name}"

module.exports = Project
