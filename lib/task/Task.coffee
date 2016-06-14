rek = require 'rekuire'
_ = require 'lodash'
Q = require 'q'
os = require 'os'
p = rek 'lib/util/prop'
Path = require './../project/Path'
Action = require './Action'
log = require('../util/logger') 'Task'
{ensureOptions} = rek 'validate'

class Task

  p @, 'configured', get : -> @_configured.promise

  p @, 'path', get : -> @_path.fullPath

  p @, 'temporaryDir', get : -> os.tmpdir()

  p @, 'failed', get : -> _.some @actions, ( x ) -> x.failed

  p @, 'failedActions', get : -> _.filter @actions, ( x ) -> x.failed

  p @, 'messages', get : ->
    _.map _.flatten(_.map @failedActions, ( x ) -> x.messages),
      ( x ) -> '> ' + x

  constructor : ( opts = {} ) ->
    ensureOptions opts, 'name', 'project', 'type'
    for p in [ 'name', 'project', 'description', 'type' ] when opts[ p ]
      @[ p ] = opts[ p ]

    @enabled = true
    @dependencies = []
    @actions = []
    @_onlyIfSpec = []
    @_path = new Path @project._path.absolutePath @name
    @_configured = Q.defer()
    @didWork = 0
    @init opts

  init : =>

  enable: (v = true) =>
    @enabled = v
    for d in @dependencies
      @project.tasks.get(d).task.enable()
    
  summary : =>
    if !@failed
      if @checkDidWork() then "OK" else "UP-TO-DATE"
    else
      msg = Array.from @messages
      msg.unshift 'FAILED'
      msg.join '\n'

  checkDidWork : =>
    return true if @didWork
    for d in @dependencies
      return true if @project.tasks.get(d).task.checkDidWork()

  onAfterEvaluate : =>
    @_configured.resolve()

  hasProperty : ( name ) =>
    log.v 'hasProperty', name
    false

  hasMethod : ( name ) =>
    name in [ 'doFirst', 'doLast' ]

  getProperty : ( name ) =>
    log.v 'getProperty', name
    return @[ name ] if name in [ 'description', 'name', 'enabled', 'path',
      'temporaryDir', 'didWork' ]
    name

  setProperty : ( name, val ) =>
    log.v 'setProperty', name
    @[ name ] = val

  dependsOn : ( paths... ) =>
    @dependencies.push if paths.length is 1 then paths[ 0 ] else paths
    @

  doFirst : ( action ) =>
    log.v 'doFirst'
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

  _set : ( name, val ) ->
    old = @[ name ]
    unless val is @[ name ]
      @[ name ] = val
      @emit 'change', name, val, old
    @

  toString : =>
    "task #{@name}"

module.exports = Task