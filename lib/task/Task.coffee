os = require 'os'
p = require './../util/prop'
Path = require './../project/Path'
Action = require './Action'

class Task

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

  constructor : ( {@name, @project, @description, @type, @runWith} ) ->
    @_dependencies = []
    @actions = []
    @_onlyIfSpec = []
    #if @project?
    @_path = new Path @project._path.absolutePath @name

  dependsOn : ( paths... ) =>
    @_dependencies.push if paths.length is 1 then paths[ 0 ] else paths
    @

  doFirst : ( action ) =>
    throw new Error "Action must not be null" unless action?
    @actions.splice 0, 0, new Action action
    @

  doFirstSync : ( action ) =>
    throw new Error "Action must not be null" unless action?
    @actions.splice 0, 0, new Action action, false
    @

  doLast : ( action ) =>
    throw new Error "Action must not be null" unless action?
    @actions.push new Action action
    @

  doLastSync : ( action ) =>
    throw new Error "Action must not be null" unless action?
    @actions.push new Action action, false
    @

  configure : ( fn ) =>
    fn.call @ if fn?

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
    
  doConfigure : =>

  toString : =>
    "task #{@name}"

module.exports = Task