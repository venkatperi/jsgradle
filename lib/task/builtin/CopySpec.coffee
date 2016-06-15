_ = require 'lodash'
rek = require 'rekuire'
prop = rek 'prop'
SourceSpec = rek 'SourceSpec'
TargetSpec = rek 'TargetSpec'
ProcessingSpec = rek 'ProcessingSpec'
{multi} = require 'heterarchy'
path = require 'path'

methods = []

for own k,v of SourceSpec.prototype when typeof v is 'function'
  methods.push k

for own k,v of TargetSpec.prototype when typeof v is 'function'
  methods.push k

for own k,v of ProcessingSpec.prototype when typeof v is 'function'
  methods.push k

class CopySpec extends multi SourceSpec, TargetSpec, ProcessingSpec

  prop @, 'root',
    get : ->
      root = @
      while (root.parent?)
        root = root.parent
      root

  prop @, 'allDest',
    get : ->
      list = (c.allDest for c in @children)
      list.push @dest if @dest?
      _.flatten list

  prop @, 'patterns',
    get : ->
      src = "#{@srcDir}/" or ''
      patterns = _.map _.flatten(c.patterns for c in @children),
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

  constructor : ( opts = {} ) ->
    for p in [ 'srcDir', 'dest', 'name', 'parent' ] when opts[ p ]?
      @[ p ] = opts[ p ]
    if opts.filter?
      @filters ?= []
      @filters.push opts.filter
    @children = []
    @methods = Array.from methods
    if opts.allMethods
      @methods.push 'from'
    @srcDir ?= '.'

  hasMethod : ( name ) =>
    name in @methods

  setChild : ( item ) =>
    @children.push item

  from : ( src, f ) =>
    item = new CopySpec srcDir : src, parent : @
    @root?.callScriptMethod item, f if f
    @setChild item

module.exports = CopySpec