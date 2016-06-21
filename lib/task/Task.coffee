rek = require 'rekuire'
_ = require 'lodash'
Q = require 'q'
os = require 'os'
p = rek 'lib/util/prop'
Path = require '../common/Path'
BaseObject = rek 'BaseObject'
Action = rek 'Action'
TaskStats = require './TaskStats'

class Task extends BaseObject

  @_addProperties
    required : [ 'name', 'project', 'type' ]
    optional : [ 'description', 'options', ]
    exported : [ 'description', 'didWork', 'enabled' ]
    exportedReadOnly : [ 'name', 'actions', 'dependencies',
      'temporaryDir' ]
    exportedMethods : [ 'doFirst', 'doLast' ]

  p @, 'path', get : -> @_path.fullPath

  p @, 'displayName', get : -> ":#{@name}"

  p @, 'capitalizedName', get : ->
    @_cache.get 'capitalizedName', => _.upperFirst @name

  p @, 'temporaryDir', get : -> os.tmpdir()

  p @, 'didWork',
    get : -> @_didWork()
    set : ( v ) -> @_taskDidWork = v

  p @, 'failedActions', get : ->
    @_cache.get 'failedActions', =>
      _.filter @actions, ( x ) -> x.failed

  _init : ( opts ) =>
    @stats = new TaskStats()
    @description ?= "task #{@name}"
    @enabled = true
    @dependencies = []
    @actions = []
    @_path = new Path @project._path.absolutePath @name
    @on 'error', =>
      @_cache.delete 'failedActions'
    super opts

  outputName : ( input ) =>

  configure : =>

  enable : ( recursive = false ) =>
    @enabled = true
    if recursive
      for d in @dependencies
        @project.tasks.get(d).task.enable(recursive)

  dependsOn : ( paths... ) =>
    @dependencies = _.flatten _.concat @dependencies, paths

  doFirst : ( action ) =>
    action = action[ 0 ] if Array.isArray action
    action = new Action(f : action, task : @) unless action instanceof Action
    @actions.splice 0, 0, action

  doLast : ( action ) =>
    action = action[ 0 ] if Array.isArray action
    throw new Error "Action must not be null" unless action?
    action = new Action(f : action, task : @) unless action instanceof Action
    @actions.push action

  compareTo : ( other ) =>
    c = @project.compareTo other.project
    return c unless c is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  toString : => "task #{@name}"

  summary : =>
    if @failed
      if @messages
        msg = Array.from @messages
      else
        msg = []
      msg.unshift 'FAILED'
      msg.join '\n'
    else
      return 'UP-TO-DATE' unless @_checkDidWork()
      str = []
      if @stats.hasFiles
        str.push "#{@stats.notCached}(#{@stats.files}) file(s)"
      str.push 'OK'
      str.join ' '

  _checkDidWork : =>
    return true if @didWork
    for d in @dependencies
      return true if @project.tasks.get(d).task._checkDidWork()

  _doAfterEvaluate : =>
    @emit 'task:afterEvaluate:start', @
    @configured = Q.try @_onAfterEvaluate
    .fail ( err ) =>
      @addError err
    .finally =>
      @emit 'task:afterEvaluate:end', @

  _onAfterEvaluate : =>

  _didWork : =>
    return true if @_taskDidWork
    return true if @stats.didWork
    false

  _checkFailed : =>
    super() or _.some @actions, ( x ) -> x.failed

  _getErrorMessages : =>
    list = _.map @failedActions, ( x ) -> x.messages
    list = _.concat list, _.map @errors, ( x ) -> x.message
    _.map _.flatten(list), ( x ) -> '> ' + x

module.exports = Task