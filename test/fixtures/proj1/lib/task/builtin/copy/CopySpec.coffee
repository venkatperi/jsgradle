SourceSpec = require './SourceSpec'

class CopySpec extends SourceSpec
  constructor :  ->
    super()
    @fileActions = []
    @filters = []
    @sources = []
    @destinations = []
    @childSpecs = []

  from : ( src, f ) =>
    sourceSpec = new SourceSpec src
    @runWith f, sourceSpec if f
    @sources.push sourceSpec

  into : ( spec ) => @destinations.push spec

  filter : ( f ) => @filters.push f

  caseSensitive : ( v ) => @_caseSensitive = v
  includeEmptyDirs : ( v ) => @_includeEmptyDirs = v
  duplicatesStrategy : ( v ) => @_duplicatesStrategy = v

  eachFile : ( f ) => @fileActions.push f
  rename : ( f ) => @_rename = f
  with : ( child ) => @childSpecs.push child

  toString : =>
    out = [ 'CopySpec' ]
    out.push "  from: #{@sources}"
    out.push "  into: #{@destinations}"
    out.join '\n'

module.exports = CopySpec