rek = require 'rekuire'
_ = require 'lodash'
Q = require 'q'
os = require 'os'
p = rek 'lib/util/prop'
Path = require './../project/Path'
Action = require './Action'
BaseObject = rek 'BaseObject'
conf = rek 'conf'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class Task extends BaseObject

  @_addProperties
    required : [ 'name', 'project', 'type' ]
    optional : [ 'description' ]
    exported : [ 'description', 'didWork', 'enabled' ]
    exportedReadOnly : [ 'name', 'actions', 'dependencies',
      'temporaryDir' ]
    exportedMethods : [ 'doFirst', 'doLast' ]

  p @, 'path', get : -> @_path.fullPath

  p @, 'displayName', get : -> ":#{@name}"

  p @, 'temporaryDir', get : -> os.tmpdir()

  p @, 'failed', get : ->
    @errors.length > 0 or _.some @actions, ( x ) -> x.failed

  p @, 'failedActions', get : ->
    @_cache.get 'failedActions', =>
      _.filter @actions, ( x ) -> x.failed

  p @, 'messages', get : ->
    @_cache.get 'messages', =>
      list = _.map @failedActions, ( x ) -> x.messages
      list = _.concat list, _.map @errors, ( x ) -> x.message
      _.map _.flatten(list), ( x ) -> '> ' + x

  init : ( opts ) =>
    @description ?= "task #{@name}"
    @enabled = true
    @dependencies = []
    @actions = []
    @errors = []
    @_onlyIfSpec = []
    @_path = new Path @project._path.absolutePath @name
    @didWork = 0
    super opts

  enable : ( v = true ) =>
    @enabled = v
    for d in @dependencies
      @project.tasks.get(d).task.enable()

  summary : =>
    @_cache.get 'summary', =>
      if @failed
        msg = Array.from @messages
        msg.unshift 'FAILED'
        msg.join '\n'
      else
        if @checkDidWork() then "OK" else "UP-TO-DATE"

  checkDidWork : =>
    @_cache.get 'checkDidWork', =>
      return true if @didWork
      for d in @dependencies
        return true if @project.tasks.get(d).task.checkDidWork()

  doAfterEvaluate : =>
    @emit 'task:afterEvaluate:start', @
    @configured = Q.try @onAfterEvaluate
    .fail ( err ) =>
      @errors.push err
    .finally =>
      @emit 'task:afterEvaluate:end', @

  onAfterEvaluate : =>

  dependsOn : ( paths... ) =>
    @dependencies.push if paths.length is 1 then paths[ 0 ] else paths
    @

  doFirst : ( action ) =>
    action = action[ 0 ] if Array.isArray action
    action = new Action(f : action, task : @) unless action instanceof Action
    @actions.splice 0, 0, action
    undefined

  doLast : ( action ) =>
    action = action[ 0 ] if Array.isArray action
    throw new Error "Action must not be null" unless action?
    action = new Action(f : action, task : @) unless action instanceof Action
    @actions.push action
    undefined

  onlyIf : ( fn ) =>
    @_onlyIfSpec.push fn

  compareTo : ( other ) =>
    c = @project.compareTo other.project
    return c unless c is 0
    return -1 if @path < other.path
    return 1 if @path > other.path
    0

  toString : => "task #{@name}"

module.exports = Task