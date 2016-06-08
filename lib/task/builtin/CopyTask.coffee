_ = require 'lodash'
Task = require '../Task'
CopySpec = require './CopySpec'
CopyAction = require './CopyAction'

class CopyTask extends Task

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts

  onAfterEvaluate : =>
    @createActions()

  createActions : =>

module.exports = CopyTask