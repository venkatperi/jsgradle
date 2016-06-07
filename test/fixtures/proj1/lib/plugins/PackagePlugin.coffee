Plugin = require './Plugin'

class PackagePlugin extends Plugin
  constructor : ->
    @name = 'package'
    @package =
      description : undefined
      keywords : []
      preferGlobal : false
      homepage : undefined
      bugs : {}
      license : undefined
      author : {}
      contributors : []
      main : undefined
      bin : undefined
      repository : {}
      scripts : {}
      man : []
      dist : {}
      gitHead : undefined
      maintainers : {}

  apply : ( project ) =>
    super project
    project.extensions.add 'pkg', @package

    project.task 'pkg', null, ( t, p ) =>
      t.doFirst ( p ) =>
        console.log "pkg: #{@package.description}"
        p.resolve()
      p.done()

module.exports = PackagePlugin