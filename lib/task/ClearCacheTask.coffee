_ = require 'lodash'
RmdirTask = require './RmdirTask'

class ClearCacheTask extends RmdirTask
  @_addProperties
    required : [ 'target' ]

  onAfterEvaluate : =>
    @dirs ?= []
    @dirs.push @project.tasks.get(@target).task.cacheDir
    super()

module.exports = ClearCacheTask