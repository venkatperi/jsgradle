_ = require 'lodash'
rek = require 'rekuire'
Convention = rek 'Convention'
_conf = rek 'conf'
SourceSetContainer = rek 'SourceSetContainer'
SourceSetOutput = rek 'SourceSetOutput'
FilesSpec = rek 'FilesSpec'
assert = require 'assert'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

sourceSet = ( name ) ->
  name = 'sourceSets:' + name.replace /\./g, ':'
  _conf.get name

class CompileConvention extends Convention

  createSourceSets : =>
    for x in [ 'main', 'test' ]
      @createSourceSet x, SourceSetContainer unless @sourceSetExists x
      assert @sourceSetExists x

      defaultKey = "#{x}.default"
      key = "#{x}.#{@name}"
      unless @sourceSetExists key
        opts = sourceSet(key) or sourceSet(defaultKey)
        opts = _.extend opts, allMethods : true, name : @name
        @createSourceSet key, FilesSpec, opts

      key = "#{x}.output"
      unless @sourceSetExists key
        opts = sourceSet(key) or dir : @project.buildDir
        @createSourceSet key, SourceSetOutput, opts

      defaultKey = "#{x}.output.default"
      key = "#{x}.output.#{@name}"
      unless @sourceSetExists key
        opts = sourceSet(key) or sourceSet(defaultKey) or {}
        opts.dir ?= '.'
        @createSourceSet key, SourceSetOutput, opts

  module.exports = CompileConvention