rek = require 'rekuire'
_ = require 'lodash'
Q = require 'q'
os = require 'os'
p = rek 'lib/util/prop'
Path = require './../project/Path'
Action = require './Action'
log = require('../util/logger') 'Task'
out = rek 'out'
BaseObject = rek 'BaseObject'
conf = rek 'conf'

class Task extends BaseObject

  @_addProperties
    required : [ 'name', 'project', 'type' ]
    optional : [ 'description' ]
    exported : [ 'description', 'didWork', 'enabled' ]
    exportedReadOnly : [ 'name', 'actions', 'dependencies',
      'temporaryDir' ]
    exportedMethods : [ 'doFirst', 'doLast' ]

  p @, 'configured', get : -> @_configured.promise

  p @, 'path', get : -> @_path.fullPath

  p @, 'displayName', get : -> ":#{@name}"

  p @, 'temporaryDir', get : -> os.tmpdir()

  p @, 'failed', get : ->
    @_cache.get 'failed',
      => _.some @actions, ( x ) -> x.failed

  p @, 'failedActions', get : ->
    @_cache.get 'failedActions',
      => _.filter @actions, ( x ) -> x.failed

  p @, 'messages', get : ->
    @_cache.get 'messages',
      => _.map _.flatten(_.map @failedActions,
        ( x ) -> x.messages), ( x ) -> '> ' + x

  init : =>
    @description ?= "task #{@name}"
    @enabled = true
    @dependencies = []
    @actions = []
    @_onlyIfSpec = []
    @_path = new Path @project._path.absolutePath @name
    @_configured = Q.defer()
    @didWork = 0

  enable : ( v = true ) =>
    @enabled = v
    for d in @dependencies
      @project.tasks.get(d).task.enable()

  summary : =>
    @_cache.get 'summary', =>
      if !@failed
        if @checkDidWork() then "OK" else "UP-TO-DATE"
      else
        msg = Array.from @messages
        msg.unshift 'FAILED'
        msg.join '\n'

  checkDidWork : =>
    @_cache.get 'checkDidWork', =>
      return true if @didWork
      for d in @dependencies
        return true if @project.tasks.get(d).task.checkDidWork()

  onAfterEvaluate : =>
    @_configured.resolve()

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