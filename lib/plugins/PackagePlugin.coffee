Plugin = require './Plugin'
rek = require 'rekuire'
PackageOptions = rek 'PackageOptions'
UpdatePkgTask = rek 'UpdatePkgTask'
TaskFactory = rek 'TaskFactory'
configurable = rek 'configurable'
fs = require 'fs'
_ = require 'lodash'

load = ( file, obj ) =>
  pkg = JSON.parse fs.readFileSync file, 'utf8'
  _.extend obj, pkg
  pkg

class PackagePlugin extends Plugin
  constructor : ->
    @name = 'package'

  apply : ( project ) =>
    super project
    #@package = new PackageOptions()
    @package = configurable(project.callScriptMethod)
    file = project.fileResolver.file 'package.json'
    pkg = load file, @package

    project.extensions.add 'pkg', @package
    project.extensions.add '__pkg', filename: file, pkg: pkg
    TaskFactory.register 'UpdatePkg', ( x ) -> new UpdatePkgTask x
    project.task 'updatePkg', type : 'UpdatePkg'
    project.defaultTasks 'updatePkg'

module.exports = PackagePlugin