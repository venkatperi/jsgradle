rek = require 'rekuire'
Task = rek 'lib/task/Task'
gulp = require 'gulp'
GulpSpec = rek 'GulpSpec'
GulpAction = require './GulpAction'
coffee = require 'gulp-coffee'

class GulpTask extends Task

  init : ( opts ) =>
    @spec = opts.spec
    @output = opts.output
    super(opts)

  setChild : ( c ) =>
    @spec ?= new GulpSpec()
    @spec.setChild c

  summary : =>
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    console.log @spec
    @_configured.resolve()
    return
    
    dest = @spec?.allDest
    dest = dest?[ 0 ] or @output
    @_configured.reject new Error "No destinations" unless dest
    gulp.task @path, =>
      gulp.src @spec.patterns
      .pipe coffee { bare : true }
      .pipe gulp.dest dest
    @doFirst new GulpAction gulp : gulp, taskName : @path, task : @
    @_configured.resolve()

module.exports = GulpTask