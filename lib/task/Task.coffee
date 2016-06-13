Q = require 'q'
os = require 'os'
p = require './../util/prop'
Path = require './../project/Path'
Action = require './Action'
log = require('../util/logger') 'Task'

class Task

  p @, 'configured', get : -> @_configured.promise

  p @, 'dependencies', get : -> @_dependencies

  p @, 'path', get : -> @_path.fullPath

  p @, 'temporaryDir', get : -> os.tmpdir()

  p @, 'description',
    get : -> @_description
    set : ( v ) -> @_set '_description', v

  p @, 'enabled',
    get : -> @_enabled
    set : ( v ) -> @_set '_enabled', v

  p @, 'didWork',
    get : -> @_didWork
    set : ( v ) -> @_set '_didWork', v

  constructor : ( {@name, @project, @description, @type} ) ->
    throw new Error "Missing option: name" unless @name and typeof @name is 'string'
    throw new Error "Missing option: type" unless @type?
    @_dependencies = []
    @actions = []
    @_onlyIfSpec = []
    @_path = new Path @project._path.absolutePath @name
    @_configured = Q.defer()
    @project.on 'afterEvaluate', @onAfterEvaluate

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
    @_dependencies.push if paths.length is 1 then paths[ 0 ] else paths
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