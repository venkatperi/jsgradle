path = require 'path'
prop = require './prop'

class OSPath

  prop @, 'isAbsolute', get : -> path.isAbsolute @path
  prop @, 'dir', get : -> @parts.dir
  prop @, 'ext', get : -> @parts.ext
  prop @, 'fileName', get : -> @parts.name
  prop @, 'root', get : -> @parts.root

  constructor : ( @path ) ->
    @path ?= process.cwd()
    @parts = path.parse @path

  normalize : => new OSPath path.normalize(@path)

  join : ( items... ) =>
    items.splice 0, 0, @path
    new OSPath path.join.apply null, items

  relative : ( to ) => new OSPath path.relative @path, to

  resolve : ( to ) => new OSPath path.resolve @path, to

  toString : => @path

module.exports = OSPath