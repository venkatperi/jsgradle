Q = require 'q'
_ = require 'lodash'
glob = require '../util/glob'

class FileSourceSet
  constructor : ( {@spec} = {} )->
    @opts =
      nodir : true
      realpath : true

  resolve : ( resolver ) =>
    res =
      includes : []
      excludes : []
    dir = resolver.file @spec.srcDir
    opts = _.extend {}, @opts
    opts.cwd = dir
    all = []

    [ 'includes', 'excludes' ].forEach ( t ) =>
      @spec[ t ].forEach ( pat ) =>
        all.push(glob pat, opts
        .then ( list ) ->
          res[ t ].push list)

    if @spec.sources.length
      children = Q.all(
        for s in @spec.sources
          new FileSourceSet spec : s
          .resolve resolver
      )
    else
      children = Q []

    children.then ( cfiles ) =>
      files = _.flatten cfiles
      Q.all(all).then ->
        files = files.concat _.flatten(res.includes)
        _.difference files, _.flatten(res.excludes)
      .then ( files ) =>
        @files = _.uniq files

module.exports = FileSourceSet