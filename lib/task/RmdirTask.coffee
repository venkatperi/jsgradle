_ = require 'lodash'
Task = require './Task'
RmdirAction = require './RmdirAction'

class RmdirTask extends Task

  onAfterEvaluate : =>
    if @dirs?
      dirs = _.map @dirs, ( x ) =>  @project.fileResolver.file x
      @doLast new RmdirAction dirs : dirs, task : @

module.exports = RmdirTask