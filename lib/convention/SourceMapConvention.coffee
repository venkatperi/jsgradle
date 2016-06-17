rek = require 'rekuire'
CompileConvention = rek 'CompileConvention'
_conf = rek 'conf'
SourceSetContainer = rek 'SourceSetContainer'
SourceSetOutput = rek 'SourceSetOutput'
CopySpec = rek 'CopySpec'

class SourceMapConvention extends CompileConvention

  createSourceSets : =>
    super()

    unless @sourceSetExists 'main.sourceMap'
      output = @getSourceSet('main.output').dir
      @createSourceSet 'main.sourceMap', SourceSetOutput, dir : "#{output}/maps"

module.exports = SourceMapConvention