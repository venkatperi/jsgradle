_ = require 'lodash'
Task = require '../Task'
CopySpec = require './CopySpec'
CopyAction = require './CopyAction'
FileSourceSet = require '../FileSourceSet'
log = require('../../util/logger')('CopyTask')

class CopyTask extends Task

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts
    @spec = new CopySpec()
    @files = new FileSourceSet spec : @spec

  onCompleted : =>
    @_configured.resolve @files.resolve @project.fileResolver

  setChild : ( child ) =>
    @spec.setChild child

module.exports = CopyTask