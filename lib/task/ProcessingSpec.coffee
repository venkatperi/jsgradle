class ProcessingSpec

  constructor : ->
    @srcNameActions = []
    @fileActions = []
    @filters = []

  filter : ( f ) => @filters.push f

  includeEmptyDirs : ( v ) => @_includeEmptyDirs = v

  duplicatesStrategy : ( v ) => @_duplicatesStrategy = v

  eachFile : ( f ) => @fileActions.push f

  rename : ( f ) => @srcNameActions.push f

module.exports = ProcessingSpec