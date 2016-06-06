Q = require 'q'
_ = require 'lodash'
Task = require '../Task'
CopySpec = require './copy/CopySpec'
{multi} = require 'heterarchy'
glob = require '../../util/glob'
ncp = require '../../util/ncp'
path = require 'path'

class CopyTask extends multi Task, CopySpec

  constructor : ( opts = {} )->
    opts.type = 'Copy'
    super opts

    @doFirst ( p ) =>
      res =
        includes : []
        excludes : []
      prev = Q(true)
      for s in @sources
        do( s ) =>
          dir = path.join @project.projectDir, s.src
          for t in [ 'includes', 'excludes' ]
            do ( t ) =>
              for pat in s[ t ]
                do ( pat ) =>
                  prev = prev.then -> glob pat, cwd : dir
                  .then ( list ) -> res[ t ].push list

      prev.then =>
        final = _.difference _.flatten(res.includes), _.flatten(res.excludes)
        ncp final, @destinations[ 0 ], (err, res) ->
          console.log err if err?
          p.done()
      .done()

  doConfigure : =>
    super()

module.exports = CopyTask