_ = require 'lodash'
rek = require 'rekuire'
prop = rek 'prop'
SourceSpec = rek 'SourceSpec'
TargetSpec = rek 'TargetSpec'
ProcessingSpec = rek 'ProcessingSpec'
{multi} = require 'heterarchy'
log = rek('logger')(require('path').basename(__filename).split('.')[0])

methods = []

for own k,v of SourceSpec.prototype when typeof v is 'function'
  methods.push k

for own k,v of TargetSpec.prototype when typeof v is 'function'
  methods.push k

for own k,v of ProcessingSpec.prototype when typeof v is 'function'
  methods.push k

class CopySpec extends multi SourceSpec, TargetSpec, ProcessingSpec

  constructor : ( opts = {} ) ->
    for p in [ 'srcDir', 'dest' ] when opts[ p ]?
      @[ p ] = opts[ p ]
    if opts.filter?
      @filters ?= []
      @filters.push opts.filter

    @children = []

  hasMethod : (name) =>
    name in  methods
    
  setChild : ( item ) =>
    @children.push item

module.exports = CopySpec