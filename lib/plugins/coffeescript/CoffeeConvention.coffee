rek = require 'rekuire'
Convention = require './CoffeeConvention'

class CoffeeConvention extends Convention

  init : ( opts ) =>
    @name = 'coffeescript'
    super opts

  createSourceSets : =>
    for x in [ 'main', 'test' ]
      @create x, SourceSetContainer unless @exists x

    unless @sourceSetExists 'main.output'
      @createSourceSet 'main.output', SourceSetOutput, dir : 'dist'

    unless @sourceSetExists 'main.coffeescript'
      src = @createSourceSet 'main.coffeescript', CopySpec, allMethods : true
      src.srcDir = 'lib'
      src.include '**/*.coffee'

    unless @sourceSetExists 'test.coffeescript'
      src = @createSourceSet 'main.coffeescript', CopySpec, allMethods : true
      src.srcDir = 'test'
      src.include '**/*.coffee'

module.exports = CoffeeConvention