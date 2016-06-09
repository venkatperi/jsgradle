_ = require 'lodash'
Task = require '../Task'
CopySpec = require './CopySpec'
CopyAction = require './CopyAction'
FileSourceSet = require '../FileSourceSet'

class CopyTask extends Task

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts
    @spec = new CopySpec()
    @files = new FileSourceSet spec : @spec

  configure : ( f, runp ) =>
    runp f, [ @ ], [ @, @spec ]
    @spec.configure runp

  afterEvaluate : =>
    @files.resolve @project.fileResolver
    .then (files) =>
      console.log files
      @createActions()

  createActions : =>

module.exports = CopyTask