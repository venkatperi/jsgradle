_ = require 'lodash'
rek = require 'rekuire'
prop = rek 'prop'
SourceSpec = rek 'SourceSpec'
TargetSpec = rek 'TargetSpec'
ProcessingSpec = rek 'ProcessingSpec'
{multi} = require 'heterarchy'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

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