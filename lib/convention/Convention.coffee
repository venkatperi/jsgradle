rek = require 'rekuire'
BaseObject = rek 'BaseObject'
prop = rek 'prop'

class Convention extends BaseObject

  apply : ( project ) =>
    return if @initialized?
    @initialized = true
    @project = project
    @createSourceSets()

  sourceSetExists : ( name ) =>
    @get(name)?

  getSourceSet : ( name ) =>
    parts = name.split '.' if typeof name is 'string'
    obj = @rootSourceSet
    for p in parts
      obj = obj[ p ] if obj[ p ]
    obj

  createSourceSet : ( path, klass, opts = {} ) =>
    throw new Error "no path" unless path?
    parts = path.split '.'
    throw new Error "empty path" unless parts.length > 0
    parent = get [ ..-2 ]
    throw new Error "bad path: #{path}" unless parent?
    [...,name] = parts
    throw new Error "item exists at path: #{path}" if parent.has name
    _opts = _.extend {}, opts
    _.extend _opts, parent : parent, name : name
    parent.add name, new klass _opts

  createSourceSets : =>

module.exports = Convention