path = require 'path'
log = require('../util/logger')('SourceSpec')

class SourceSpec
  
  hasMethod : ( name ) =>
    name in [ 'include', 'exclude', 'caseSensitive' ]

  caseSensitive : ( val ) => @_caseSensitive = val

  with : ( srcs... ) => @sources.push s for s in srcs

  include : ( items ) =>
    log.v 'include', items
    @includes ?= []
    @includes.push i for i in items

  exclude : ( items... ) =>
    @excludes ?= []
    @excludes.push i for i in items

  configure : ( run ) =>
    log.i 'configure'
    if @parent?
      @srcDir = path.join @parent.srcDir, @srcDir
    @includes.push '**/*' if @includes.length is 0

    @sources.forEach ( s ) ->
      s.configure run
    run @, @configClosure if @configClosure?

module.exports = SourceSpec