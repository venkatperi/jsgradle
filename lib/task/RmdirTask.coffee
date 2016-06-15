_ = require 'lodash'
Task = require './Task'
rek = require 'rekuire'
{ensureOptions} = rek 'validate'
RmdirAction = require './RmdirAction'

class RmdirTask extends Task

  @_addProperties
    required : [ 'dirs' ]

  summary : =>
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    dirs = _.map @dirs, ( x ) =>  @project.fileResolver.file x
    @doLast new RmdirAction dirs : dirs, task : @
    super()

module.exports = RmdirTask