Q = require 'q'
_ = require 'lodash'
rek = require 'rekuire'
glob = rek 'lib/util/glob'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class FileSourceSet
  constructor : ( {@spec} = {} )->
    @opts =
      nodir : true
      realpath : true

  resolve : ( resolver ) =>
    res =
      includes : []
      excludes : []

    files = []
    if @spec.children?
      children = Q.all(for s in @spec.children
        new FileSourceSet spec : s
        .resolve resolver)
    else
      children = Q([])

    children.then ( list ) =>
      files.push _.flatten list
      #return files unless @spec.srcDir
      srcDir = @spec.srcDir or '.'
      dir = resolver.file srcDir
      opts = _.extend {}, @opts
      opts.cwd = dir

      all = []
      [ 'includes', 'excludes' ].forEach ( t ) =>
        if @spec[ t ]
          @spec[ t ].forEach ( pat ) ->
            all.push(glob pat, opts
            .then ( list ) ->
              res[ t ].push list)

      Q.all(all).then ->
        files = files.concat _.flatten(res.includes)
        _.difference files, _.flatten(res.excludes)
    .then ( files ) =>
      @files = _.uniq _.flatten files

module.exports = FileSourceSet