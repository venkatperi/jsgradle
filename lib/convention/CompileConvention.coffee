rek = require 'rekuire'
Convention = rek 'Convention'
_conf = rek 'conf'
SourceSetContainer = rek 'SourceSetContainer'
SourceSetOutput = rek 'SourceSetOutput'

get = ( name ) ->
  _conf.get("convention:coffeescript:#{name}") or
    _conf.get("convention:#{name}")

class CompileConvention extends Convention

  createSourceSets : =>
    for x in [ 'main', 'test' ]
      @createSourceSet x, SourceSetContainer unless @sourceSetExists x

    unless @sourceSetExists 'main.output'
      @createSourceSet 'main.output', SourceSetOutput, dir : get 'output:dir'

module.exports = CompileConvention