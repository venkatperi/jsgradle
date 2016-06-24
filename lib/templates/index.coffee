handlebars = require 'handlebars'
rek = require 'rekuire'
conf = rek 'conf'
{isFileSync, writeFileMkdirSync, readFileSync} = rek 'fileOps'
cache = require('guava-cache')
path = require 'path'
{EventEmitter} = require 'events'

class Template extends EventEmitter

  constructor : ( opts = {} )->
    @dir = opts.dir or __dirname
    @ext = opts.ext or 'hbr'
    @cache = cache()
    @cache.on 'error', ( err ) => @emit 'error', err

  load : ( name ) =>
    contents = readFileSync(path.join(@dir, "#{name}.#{@ext}"), 'utf8')
    handlebars.compile contents

  get : ( name ) =>
    @cache.get name, @load

  render : ( name, context ) =>
    @get(name)(context)

  generate : ( name, context, outPath ) =>
    unless isFileSync outPath
      writeFileMkdirSync outPath, @render(name, context)

module.exports = Template