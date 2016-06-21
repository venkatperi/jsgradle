_ = require 'lodash'
rek = require 'rekuire'
GulpThrough = rek 'GulpThrough'
GlobChanges = require('glob-changes').GlobChanges

class ChangedFiles extends GulpThrough
  constructor : ( opts = {} ) ->
    super opts
    for p in [ 'name', 'patterns' ]
      throw new Error "Missing option: #{p}" unless opts[p]

    @stats =
      total : 0
      modified : 0

    _opts = _.extend {}, realpath : true, opts
    globber = opts.globChanges or new GlobChanges(opts)
    @ready = globber.changes opts.name, opts.patterns, _opts
    .then ( files ) =>
      @modified = {}
      for f in  _.union files.added, files.changed
        @modified[ f ] = f
      @removed = files.removed

  onData : ( f, e ) =>
    @ready.then =>
      @stats.total++
      if @modified[ f.path ]
        @stats.modified++
        return f

module.exports = ChangedFiles
    
