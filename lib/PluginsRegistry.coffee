fs = require 'fs'
path = require 'path'
_ = require 'lodash'

pluginRegex = /(\w+)Plugin\.coffee/

class PluginsRegistry
  constructor : ->
    @items = new Map()
    @loadInternal()

  loadInternal : =>
    dir = path.join __dirname, 'plugins'
    files = _.filter fs.readdirSync(dir), ( x ) -> x.match pluginRegex
    for f in files
      name = f.match(pluginRegex)[ 1 ]
      plugin = require path.join dir, f
      @items.set _.lowerFirst(name), plugin

  has : ( name ) => @items.has name

  get : ( name ) => @items.get name

module.exports = PluginsRegistry