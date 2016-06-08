path = require 'path'
Q = require 'q'
_ = require 'lodash'
glob = require '../util/glob'

class SourceSpec
  constructor : ( {
  @srcDir, @parent, @configurator
  } = {} ) ->
    @srcDir ?= '.'
    @includes = []
    @excludes = []
    @sources = []
    @opts =
      nodir : true
      realpath : true

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

  ignoreCase : ( val ) =>
    @opts.nocase = val

  with : ( srcs... ) =>
    @sources.push s for s in srcs

  include : ( items... ) =>
    @includes.push i for i in items
    @

  exclude : ( items... ) =>
    @excludes.push i for i in items
    @

  toString : =>
    "SourceSpec{src: #{@srcDir}, includes: #{@includes}, excludes: #{@excludes}"

  doConfigure : ( run ) =>
    if @parent?
      @srcDir = path.join @parent.srcDir, @srcDir
    @includes.push '**/*' if @includes.length is 0

    @sources.forEach ( s ) ->
      s.doConfigure run
    run @configurator, @ if @configurator and run?

  resolve : ( resolver ) =>
    res =
      includes : []
      excludes : []
    dir = resolver.file @srcDir
    opts = _.extend {}, @opts
    opts.cwd = dir
    all = []
    [ 'includes', 'excludes' ].forEach ( t ) =>
      @[ t ].forEach ( pat ) =>
        all.push(glob pat, opts
        .then ( list ) ->
          res[ t ].push list)

    if @sources.length
      children = Q.all(s.resolve resolver for s in @sources)
    else
      children = Q []

    children.then ( cfiles ) =>
      files = _.flatten cfiles
      Q.all(all).then ->
        files = files.concat _.flatten(res.includes)
        _.difference files, _.flatten(res.excludes)
      .then ( files ) =>
        @files = _.uniq files

module.exports = SourceSpec