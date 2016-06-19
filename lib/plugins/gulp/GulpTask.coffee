Q = require 'q'
rek = require 'rekuire'
Task = rek 'lib/task/Task'
objectOmit = require 'object.omit'
objectAssign = require 'object-assign'
File = require 'vinyl'
gulp = require 'gulp'
cache = require 'gulp-cache'
GulpSpec = rek 'GulpSpec'
GulpAction = require './GulpAction'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
conf = rek 'conf'

restore = ( restored ) ->
  if restored.contents
    # Handle node 0.11 buffer to JSON as object with { type: 'buffer', data: [...] }
    if restored and restored.contents and Array.isArray(restored.contents.data)
      restored.contents = new Buffer(restored.contents.data)
    else if Array.isArray(restored.contents)
      restored.contents = new Buffer(restored.contents)
    else if typeof restored.contents == 'string'
      restored.contents = new Buffer(restored.contents, 'base64')
  restoredFile = new File(restored)
  extraTaskProperties = objectOmit(restored, Object.keys(restoredFile))
  restoredFile.fromCache = true
  # Restore any properties that the original task put on the file;
  # but omit the normal properties of the file
  objectAssign restoredFile, extraTaskProperties

class GulpTask extends Task

  @_addProperties
    required : [ 'gulpType' ]
    optional : [ 'spec', 'output', 'options', 'gulpType', 'noCache' ]

  setChild : ( c ) =>
    @spec ?= new GulpSpec()
    @spec.setChild c

  onAfterEvaluate : =>
    gulpPlugin = require(@gulpType)(@options)
    unless @noCache
      gulpPlugin = cache gulpPlugin,
        fileCache : new cache.Cache
          cacheDirName : 'kohi-cache'
        name : @name
        restore: restore

    dest = @output
    dest ?= @spec?.allDest?[ 0 ]
    throw new Error "No destinations" unless dest

    gulpPlugin.on 'data', ( file ) =>
      @stats.file file.fromCache

    gulp.task @path, =>
      gulp.src @spec.patterns, base : '.'
      .pipe gulpPlugin
      .pipe gulp.dest dest

    @doFirst new GulpAction
      gulp : gulp,
      taskName : @path,
      task : @

module.exports = GulpTask
