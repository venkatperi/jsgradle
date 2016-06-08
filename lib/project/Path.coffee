SEP = ':'

prop = require './../util/prop'

isAbsolute = ( path ) ->
  path?.indexOf(SEP) is 0

###
Public: Represents path to a project/task

###
class Path
  @SEP : SEP

  prop @, 'depth', get : -> @_segments.length
  prop @, 'path', get : -> @fullPath

  ###
  Public: Create a new path object
 
  * `path` (optional) {String} Initial path of this object 
  ###
  constructor : ( path, absolute = true )->
    @_segments = []
    @absolute = absolute
    if typeof path is 'string'
      @absolute = isAbsolute path
      path = path[ 1.. ] if @absolute
      @_segments = path.split SEP
    else if Array.isArray path
      @_segments = path
      @absolute = absolute

    @fullPath = @_segments.join SEP
    @fullPath = SEP + @fullPath if @absolute
    @prefix = if @fullPath[ -1 ] is SEP then @fullPath else @fullPath + SEP

  toString : => @fullPath

  ###
  Public: Returns the parent of this path, or null if this path 
  has no parent.
  
  Returns {Path} parent of this path or null
  ###
  parent : =>
    return unless @_segments.length
    if @depth is 1
      return if @absolute then new Path() else undefined
    new Path @_segments[ 0..@_segments.length - 2 ], @absolute

  absolutePath : ( path ) =>
    console.log path
    path = @prefix + path unless isAbsolute(path)
    path

  relativePath : ( path ) =>
    if path.length > @prefix.length and path.indexOf(@prefix) is 0
      return path[ @prefix.length.. ]
    path

module.exports = Path