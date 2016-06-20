rek = require 'rekuire'
_ = require 'lodash'
Q = require 'q'
os = require 'os'
p = rek 'lib/util/prop'
Path = require './../project/Path'
Action = require './Action'
BaseObject = rek 'BaseObject'
conf = rek 'conf'
Task = rek 'Task'
TaskStats = require './TaskStats'
FileCache = rek 'FileCache'
sha1 = require 'sha1'

class CachingTask extends Task

  @_addProperties
    optional : [ 'noCache' ]

  p @, 'fileCache', get : ->
    @_cache.get 'fileCache',
      => new FileCache cacheDirName : 'cache', category : @name

  p @, 'cacheDir', get : ->
    @_cache.get 'cacheDir',
      => @project.fileResolver.file @fileCache.cacheDir

  configure : =>
    @didOptionsChange()

  didOptionsChange : =>
    name = "clearCache#{@capitalizedName}"
    hash = sha1 JSON.stringify @options
    @fileCache.get(hash)
    .then ( v ) =>
      return if v?
      @dependsOn name
      @cacheOptions()

  cacheOptions : =>
    return unless @options
    @doLast =>
      opt = JSON.stringify @options
      hash = sha1 opt
      @fileCache.set(hash, opt)

module.exports = CachingTask