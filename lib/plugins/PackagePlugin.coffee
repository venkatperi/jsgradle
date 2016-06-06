Plugin = require './Plugin'

class PackagePlugin extends Plugin
  constructor : ->
    @name = 'package'
    @package =
      description : undefined
      keywords : []
      preferGlobal : false
      config : {}
      directories : {}
      homepage : undefined
      bugs : {}
      license : undefined
      author : {}
      contributors : []
      main : undefined
      bin : undefined
      repository : {}
      dependencies : {}
      bundleDependencies : []
      devDependencies : {}
      scripts : {}
      man : []
      dist : {}
      gitHead : undefined
      maintainers : {}

  apply : ( project ) =>
    super project
    project.extensions.add @name, @package
    

module.exports = PackagePlugin