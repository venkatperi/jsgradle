Q = require 'q'
rek = require 'rekuire'
Task = rek 'lib/task/Task'
gulp = require 'gulp'
GulpSpec = rek 'GulpSpec'
GulpAction = require './GulpAction'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
through = require 'through'

countFiles = ( cb ) ->
  count = 0

  countFiles = ( data ) ->
    count++
    @queue data

  endStream = ->
    cb? null, count
    @queue null

  through countFiles, endStream

class GulpTask extends Task

  @_addProperties
    required : [ 'gulpType' ]
    optional : [ 'spec', 'output', 'options', 'gulpType' ]

  setChild : ( c ) =>
    @spec ?= new GulpSpec()
    @spec.setChild c

  summary : =>
    return super() if @failed
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    gulpPlugin = require @gulpType
    dest = @spec?.allDest
    dest = dest?[ 0 ] or @output
    throw new Error "No destinations" unless dest

    gulp.task @path, =>
      gulp.src @spec.patterns
      .pipe countFiles ( err, count ) => @didWork = count
      .pipe gulpPlugin @options
      .pipe gulp.dest dest

    @doFirst new GulpAction
      gulp : gulp,
      taskName : @path,
      task : @


module.exports = GulpTask