_ = require 'lodash'
FileTask = require '../FileTask'
CopySpec = require './CopySpec'
CopyAction = require './CopyAction'

class CopyTask extends FileTask

  init : ( opts = {} ) =>
    opts = _.extend opts,
      spec : new CopySpec()
      actionType : CopyAction
    super opts

  setChild : ( child ) =>
    @spec.setChild child

module.exports = CopyTask