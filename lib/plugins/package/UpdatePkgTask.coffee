rek = require 'rekuire'
Task = rek 'lib/task/Task'
UpdatePkgAction = require './UpdatePkgAction'
prop = rek 'prop'
deepEqual = require 'deep-equal'

class UpdatePkgTask extends Task

  prop @, 'pkg', get : -> @project.extensions.get 'pkg'

  onAfterEvaluate : =>
    pkg = @project.extensions.get 'pkg'
    originalPkg = @project.extensions.get '__pkg'

    unless deepEqual pkg, originalPkg.pkg
      @doLast new UpdatePkgAction
        task : @,
        filename : originalPkg.filename,
        pkg : pkg

module.exports = UpdatePkgTask
