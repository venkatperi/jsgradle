rek = require 'rekuire'
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

  _init : =>
    super()
    @_createSpec()

  _createSpec : =>
    @spec ?= new FileSpec()

module.exports = CachingTask