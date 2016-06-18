_ = require 'lodash'
rek = require 'rekuire'
prop = rek 'prop'
path = require 'path'
Collection = rek 'Collection'

class CopySpec extends Collection

  prop @, 'allOptions',
    get : ->
      list = []
      @forEach ( c ) ->
        list.push (if c.__factory is 'options' then c else c.allOptions)
      _.flatten list

  prop @, 'allDest',
    get : ->
      list = @map ( c ) -> c.allDest
      list.push @dest if @dest?
      _.flatten list

  prop @, 'patterns',
    get : ->
      src = "#{@srcDir}/" or ''
      patterns = _.map _.flatten(@map ( c ) -> c.patterns),
        ( x ) ->
          prefix = ''
          [x,prefix] = [ x[ 1.. ], '!' ] if x[ 0 ] is '!'
          "#{prefix}#{src}#{x}"
      patterns = patterns.concat _.map @includes, ( x ) -> "#{src}#{x}"
      patterns = patterns.concat _.map @excludes, ( x ) -> "!#{src}#{x}"
      _.map patterns, ( x ) ->
        prefix = ''
        [x,prefix] = [ x[ 1.. ], '!' ] if x[ 0 ] is '!'
        prefix + path.normalize(x)

  @_addProperties
    optional : [ 'srcDir', 'dest', 'includes', 'excludes' ]
    exportedMethods : [ 'caseSensitive', 'with', 'include', 'exclude', 'from',
      'into' ]

  init : ( opts = {} ) =>
    super opts
    @loadFrom opts.from if opts.from?
    if opts.filter?
      @filters ?= []
      @filters.push opts.filter
    @srcDir ?= '.'

  loadFrom : ( from ) =>
    @srcDir = from.srcDir if from.srcDir
    @include i for i in from.includes if from.includes
    @exclude i for i in from.excludes if from.excludes

  caseSensitive : ( val ) => @_caseSensitive = val

  with : ( srcs... ) => @sources.push s for s in srcs

  include : ( items... ) =>
    @includes ?= []
    @includes.push i for i in _.flatten items

  exclude : ( items... ) =>
    @excludes ?= []
    @excludes.push i for i in _.flatten items

  from : ( src, f ) =>
    item = new CopySpec srcDir : src, parent : @
    @root?.callScriptMethod item, f if f
    @setChild item

  into : ( dir ) =>
    @dest = dir

  filter : ( f ) =>
    @filters ?= []
    @filters.push f

  includeEmptyDirs : ( v ) =>
    @_includeEmptyDirs = v

  duplicatesStrategy : ( v ) =>
    @_duplicatesStrategy = v

  eachFile : ( f ) =>
    @fileActions ?= []
    @fileActions.push f

  rename : ( f ) =>
    @srcNameActions ?= []
    @srcNameActions.push f

module.exports = CopySpec