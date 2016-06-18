rek = require 'rekuire'
prop = rek 'prop'

class TaskStats
  prop @, 'didWork', get : -> @notCached > 0 

  prop @, 'hasFiles', get : -> @files?

  prop @, 'notCached', get : -> @files - @cached

  constructor : () ->

  file : ( cached ) =>
    @files ?= 0
    @files++
    if cached
      @cached ?= 0
      @cached++

module.exports = TaskStats