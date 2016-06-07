class SourceSpec
  constructor : ( @src )->
    @includes = []
    @excludes = []

  include : ( items... ) =>
    @includes.push i for i in items

  exclude : ( items... ) =>
    @excludes.push i for i in items

  toString : =>
    "SourceSpec{src: #{@src}, includes: #{@includes}, excludes: #{@excludes}"

module.exports = SourceSpec