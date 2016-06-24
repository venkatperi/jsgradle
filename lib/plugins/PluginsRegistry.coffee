rek = require 'rekuire'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
Collection = rek 'lib/common/Collection'
conf = rek 'conf'

pluginRegex = /(\w+)Plugin\.coffee/

class PluginsRegistry extends Collection

  @_addProperties
    required : [ 'project' ]

  constructor : ( opts = {} )->
    super _.extend {}, opts, convertName : ( x ) -> _.lowerFirst x
    @_loadInternal()
    @_loadGulpPlugins()

  _loadInternal : =>
    dir = path.join __dirname, '../plugins'
    files = _.filter fs.readdirSync(dir), ( x ) -> x.match pluginRegex
    for f in files
      name = f.match(pluginRegex)[ 1 ]
      plugin = require path.join dir, f
      @add name, plugin

  _loadGulpPlugins : =>
    for own k,v of conf.get('plugins') when v.uses is 'GulpCompilePlugin'
      upper = _.upperFirst k
      dest = @project.file conf.get 'project:build:genDir'
      destFile = path.join dest, "#{upper}Plugin.coffee"
      @project.templates.generate 'GulpPluginClass',
        name : upper, super : v.uses, destFile
      plugin = require destFile
      @add upper, plugin

module.exports = PluginsRegistry