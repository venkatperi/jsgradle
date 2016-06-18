_ = require 'lodash'
rek = require 'rekuire'
BaseObject = rek 'BaseObject'
Dependency = rek 'Dependency'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
semver = require 'semver'

parse = ( a... ) ->
  return [] unless a.length > 0
  d = Dependency.create a...
  return [ d ] if d?
  deps = _.map a, ( x ) -> Dependency.create x
  if _.some(deps, ( x ) -> !x)
    throw new Error "Invalid dependencies: #{a}"
  deps

class DependenciesExt extends BaseObject

  onConfigurationAdded : ( name, configuration ) =>
    @[ name ] = ( args... ) =>
      deps = parse args...
      for d in deps
        configuration.dependencies.add d.name, d
    @_properties.exportedMethods ?= []
    @_properties.exportedMethods.push name

module.exports = DependenciesExt