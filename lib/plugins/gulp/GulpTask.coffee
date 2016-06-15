_ = require 'lodash'
rek = require 'rekuire'
Task = rek 'lib/task/Task'
gulp = require 'gulp'
GulpSpec = rek 'GulpSpec'
GulpAction = require './GulpAction'

PREFIX = 'Gulp'

class GulpTask extends Task

  @_addProperties
    required : [ 'spec' ]
    optional : [ 'output', 'options', 'gulpType' ]

  setChild : ( c ) =>
    @spec ?= new GulpSpec()
    @spec.setChild c

  summary : =>
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    gulpType = @gulpType
    unless gulpType
      gulpType = _.lowerFirst @type[ PREFIX.length.. ]
      throw new Error "Bad gulp plugin: gulp-#{gulpType}" unless gulpType.length > 0
      gulpType = gulp + gulpType

    gulpPlugin = require gulpType

    dest = @spec?.allDest
    dest = dest?[ 0 ] or @output
    throw new Error "No destinations" unless dest

    gulp.task @path, =>
      gulp.src @spec.patterns
      .pipe gulpPlugin @options
      .pipe gulp.dest dest

    @doFirst new GulpAction
      gulp : gulp,
      taskName : @path,
      task : @

    @_configured.resolve()

module.exports = GulpTask