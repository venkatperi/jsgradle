rek = require 'rekuire'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
Collection = rek 'lib/util/Collection'

pluginRegex = /(\w+)Plugin\.coffee/

class PluginsRegistry extends Collection
  constructor : ->
    super convertName : ( x ) -> _.lowerFirst x
    @_loadInternal()

  _loadInternal : =>
    dir = path.join __dirname, '../plugins'
    files = _.filter fs.readdirSync(dir), ( x ) -> x.match pluginRegex
    for f in files
      name = f.match(pluginRegex)[ 1 ]
      plugin = require path.join dir, f
      @add name, plugin

module.exports = PluginsRegistry