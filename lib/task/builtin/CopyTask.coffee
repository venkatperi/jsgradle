Q = require 'q'
_ = require 'lodash'
Task = require '../Task'
CopySpec = require './copy/CopySpec'
CopyAction = require './CopyAction'
{multi} = require 'heterarchy'
glob = require '../../util/glob'
path = require 'path'

class CopyTask extends multi Task, CopySpec

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts

  onAfterEvaluate : =>
    @createActions()

  createActions : =>
    dest = @destinations[ 0 ]
    @resolveSourceFiles()
    .then ( files ) =>
      for f in files
        @actions.push new CopyAction f, dest, @, cwd : @project.projectDir

          #prev = prev
          #.then -> glob pat, cwd : dir
          #.then ( list ) ->
          #  res[ t ].push (path.join s.srcDir, i for i in list)

    prev.then ->
      _.difference _.flatten(res.includes), _.flatten(res.excludes)

module.exports = CopyTask