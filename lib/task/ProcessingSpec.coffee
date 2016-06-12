log = require('../util/logger')('ProcessingSpec')

class ProcessingSpec

  filter : ( f ) =>
    @filters ?= []
    @filters.push f

  includeEmptyDirs : ( v ) => @_includeEmptyDirs = v

  duplicatesStrategy : ( v ) => @_duplicatesStrategy = v

  eachFile : ( f ) => 
    @fileActions ?= []
    @fileActions.push f

  rename : ( f ) =>
    @srcNameActions ?= []
    @srcNameActions.push f

module.exports = ProcessingSpec