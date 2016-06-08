FileSourceSet = require './FileSourceSet'
SourceSpec = require './SourceSpec'

class CoffeeSourceSet extends FileSourceSet

  constructor : ( @name ) ->
    @name ?= 'coffeescript'
    spec = new SourceSpec()
    .include '*.coffee'
    spec.sources.push new SourceSpec 'lib'
    .include '**/*.coffee'
    super spec : spec

module.exports = CoffeeSourceSet