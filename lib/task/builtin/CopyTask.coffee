_ = require 'lodash'
rek = require 'rekuire'
FileTask = require '../FileTask'
CopySpec = rek 'FilesSpec'
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