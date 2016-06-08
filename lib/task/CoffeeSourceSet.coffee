SourceSet = require './SourceSet'
SourceSpec = require './SourceSpec'

class CoffeeSourceSet extends SourceSet

  constructor : ( @name ) ->
    @name ?= 'coffeescript'
    @sources = []
    @sources.push new SourceSpec('lib')
    .include '**/*.coffee'
    @sources.push new SourceSpec('root')
    .include 'index.coffee'

module.exports = CoffeeSourceSet