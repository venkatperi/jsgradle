rek = require 'rekuire'
os = require 'os'
p = rek 'lib/util/prop'
Path = require './../common/Path'
Action = require './Action'
BaseObject = rek 'BaseObject'
conf = rek 'conf'
Task = rek 'Task'
TaskStats = require './TaskStats'
FileCache = rek 'FileCache'
sha1 = require 'sha1'
GlobChanges = require('glob-changes').GlobChanges

class CachingTask extends Task

  @_addProperties
    optional : [ 'noCache' ]

  p @, 'targetDir', get : ->
    dest = @output
    dest ?= @spec?.allDest?[ 0 ]
    dest

  p @, 'fileCache', get : ->
    @_cache.get 'fileCache',
      => new FileCache cacheDirName : 'cache', category : @name

  p @, 'cacheDir', get : ->
    @_cache.get 'cacheDir',
      => @project.fileResolver.file @fileCache.cacheDir

  p @, 'changedFiles', get : ->
    new GlobChanges(fileCache : @fileCache).changes @name, @spec.patterns,
      realpath: true

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

  _init : =>
    super()
    @_createSpec()

  _createSpec : =>
    @spec ?= new FileSpec()

module.exports = CachingTask