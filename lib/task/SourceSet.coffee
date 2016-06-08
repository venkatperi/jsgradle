SourceSpec = require './SourceSpec'

class SourceSet extends SourceSpec
  constructor: ->
    @sources = []

  from : ( src, f ) =>
    sourceSpec = new SourceSpec src
    @runWith f, sourceSpec if f
    @sources.push sourceSpec

  with: (srcs...) =>
    @sources.push s for s in srcs




module.exports = SourceSet