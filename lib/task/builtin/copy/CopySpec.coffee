SourceSpec = require '../../SourceSpec'

class CopySpec extends SourceSpec
  constructor : ->
    super()
    @srcNameActions = []
    @fileActions = []
    @filters = []
    @destinations = []

  into : ( dir ) => @destDir = dir

  filter : ( f ) => @filters.push f

  caseSensitive : ( v ) => @_caseSensitive = v

  includeEmptyDirs : ( v ) => @_includeEmptyDirs = v

  duplicatesStrategy : ( v ) => @_duplicatesStrategy = v

  eachFile : ( f ) => @fileActions.push f

  rename : ( f ) => @srcNameActions.push f

  toString : =>
    out = [ 'CopySpec' ]
    out.push "  from: #{@sources}"
    out.push "  into: #{@destinations}"
    out.join '\n'

module.exports = CopySpec