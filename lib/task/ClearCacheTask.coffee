_ = require 'lodash'
RmdirTask = require './RmdirTask'

class ClearCacheTask extends RmdirTask
  @_addProperties
    optional : [ 'target' ]

  onAfterEvaluate : =>
    @dirs ?= []
    if @target
      dir = @project.tasks.get(@target).task.cacheDir
    else
      dir @project.cacheDir
    @dirs.push dir if dir?
    super()

module.exports = ClearCacheTask