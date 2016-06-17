_ = require 'lodash'
rek = require 'rekuire'
BaseObject = rek 'BaseObject'
prop = rek 'prop'
Configuration = rek 'Configuration'

class Convention extends BaseObject

  apply : ( project ) =>
    return if @initialized?
    @initialized = true
    @project = project
    @createConfigurations?()
    @createSourceSets?()

  sourceSetExists : ( name ) => @getSourceSet(name)?

  getSourceSet : ( name ) => @project.sourceSets.get name

  configurationExists : ( name ) => @getConfiguration(name)?

  getConfiguration : ( name ) => @project.configurations.get name

  createConfiguration : ( name ) =>
    @project.configurations.add name, new Configuration(name : name)

  createSourceSet : ( path, klass, opts = {} ) =>
    throw new Error "no path" unless path?
    parts = path.split '.'
    throw new Error "empty path" unless parts.length > 0
    parentName = parts[ ..-2 ]
    [...,name] = parts
    parent = (if parentName.length is 0 then @project.sourceSets else
      @getSourceSet parentName.join '.')
    throw new Error "bad path: #{path}" unless parent?

    throw new Error "item exists at path: #{path}" if parent.get(name)?
    _opts = _.extend {}, opts
    _.extend _opts, parent : parent, name : name
    item = new klass _opts
    parent.add name, item
    item

module.exports = Convention