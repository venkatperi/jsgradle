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

  doApply : =>
    @package = configurable(@project.callScriptMethod)

    file = project.fileResolver.file 'package.json'
    pkg = load file, @package

    @register
      extensions :
        pkg : @package
        __pkg : { filename : file, pkg : pkg }
      taskFactory :
        UpdatePkg : UpdatePkgTask
        
    @createTask 'updatePkg', type : 'UpdatePkg'
    project.defaultTasks 'updatePkg'

module.exports = PackagePlugin