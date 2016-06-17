rek = require 'rekuire'
SourceMapConvention = rek 'SourceMapConvention'
_conf = rek 'conf'
SourceSetContainer = rek 'SourceSetContainer'
SourceSetOutput = rek 'SourceSetOutput'
CopySpec = rek 'CopySpec'

get = ( name ) ->
  _conf.get("convention:coffeescript:#{name}") or
    _conf.get("convention:#{name}")

class CoffeeConvention extends SourceMapConvention

  createSourceSets : =>
    super()

    unless @sourceSetExists 'main.coffeescript'
      src = @createSourceSet 'main.coffeescript', CopySpec, allMethods : true
      for d in get('main:dirs')
        src.include "#{d}/**/*.coffee"

    unless @sourceSetExists 'test.coffeescript'
      src = @createSourceSet 'test.coffeescript', CopySpec, allMethods : true
      for d in get('test:dirs')
        src.include "#{d}/**/*.coffee"

module.exports = CoffeeConvention