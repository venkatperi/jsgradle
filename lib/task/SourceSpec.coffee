path = require 'path'

class SourceSpec
  constructor : ( {@srcDir, @parent, @configurator} = {} ) ->
    @srcDir ?= '.'
    @includes = []
    @excludes = []
    @sources = []

  from : ( src, f ) =>
    switch arguments.length
      when 1
        @srcDir = src
      when 2
        @sources.push new SourceSpec
          srcDir : src,
          configurator : f,
          parent : @
      else
        throw new Error "err..."

  caseSensitive : ( val ) =>
    @_caseSensitive = val

  with : ( srcs... ) =>
    @sources.push s for s in srcs

  include : ( items... ) =>
    @includes.push i for i in items
    @

  exclude : ( items... ) =>
    @excludes.push i for i in items
    @

  doConfigure : ( run ) =>
    if @parent?
      @srcDir = path.join @parent.srcDir, @srcDir
    @includes.push '**/*' if @includes.length is 0

    @sources.forEach ( s ) ->
      s.doConfigure run
    run @configurator, @ if @configurator and run?

module.exports = SourceSpec