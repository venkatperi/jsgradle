Q = require 'q'
_ = require 'lodash'
Task = require '../Task'
CopySpec = require './copy/CopySpec'
{multi} = require 'heterarchy'
glob = require '../../util/glob'
path = require 'path'

class CopyTask extends multi Task, CopySpec

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts

  onAfterEvaluate : ( p ) =>
    @resolveSourceFiles()
    .then ( files ) ->
      console.log files

  createActions : =>
    dest = @destinations[ 0 ]
    @resolveSourceFiles()
    .then ( files ) ->
      console.log files

  resolveSourceFiles : =>
    res =
      includes : []
      excludes : []
    prev = Q(true)
    baseDir = @project.projectDir
    @sources.forEach ( s ) ->
      dir = path.join baseDir, s.src
      [ 'includes', 'excludes' ].forEach ( t ) ->
        s[ t ].forEach ( pat ) ->
          prev = prev
          .then -> glob pat, cwd : dir
          .then ( list ) ->
            res[ t ].push (path.join dir, i for i in list)

    prev.then ->
      _.difference _.flatten(res.includes), _.flatten(res.excludes)

module.exports = CopyTask