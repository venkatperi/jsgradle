_ = require 'lodash'
rek = require 'rekuire'
CachingTask = rek 'lib/task/CachingTask'
gulp = require 'gulp'
cache = require 'gulp-cache'
GulpSpec = rek 'GulpSpec'
GulpAction = require './GulpAction'
conf = rek 'conf'
path = require 'path'
{changeExt} = rek 'fileOps'
CountFiles = rek 'CountFiles'

class GulpTask extends CachingTask

  @_addProperties
    optional : [ 'spec', 'output', 'base', 'outputExt', 'package' ]

  setChild : ( c ) =>
    @spec.setChild c

  outputName : ( inputName ) =>
    out = path.join @targetDir, inputName
    changeExt out, ".#{@outputExt}" if @outputExt
    out

  _onAfterEvaluate : =>
    @changedFiles.then ( files ) =>
      return unless files?

      modified = _.union files.added, files.changed
      @stats.files = files.all.length

      unless modified.length > 0
        @stats.cached = files.all.length
        return

      srcOpts = {}
      srcOpts.base = @base if @base

      dest = @targetDir
      throw new Error "No destinations" unless dest
      
      counter = new CountFiles()
      counter.on 'count', ( count ) =>
        @stats.cached = @stats.files - count

      gulp.task @path, =>
        plugin = require(@package)(@options)

        gulp.src modified, srcOpts
        .pipe counter.plugin
        .pipe plugin
        .pipe gulp.dest(dest)

      @doFirst new GulpAction
        gulp : gulp,
        taskName : @path,
        task : @

  _createSpec : =>
    @spec ?= new GulpSpec()

module.exports = GulpTask
