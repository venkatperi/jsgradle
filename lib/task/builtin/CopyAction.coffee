os = require 'os'
Action = require '../Action'
path = require 'path'
log = require('../../util/logger') 'CopyAction'
{copyFile} = require '../../util/fileOps'
split = require 'split'

class CopyAction extends Action
  constructor : ( @src, @dest, @copySpec, @opts ) ->

  exec : =>
    cwd = @opts.cwd or process.cwd()
    src = if @src[ 0 ] is path.sep then @src else path.join cwd, @src
    src = f src for f in @copySpec.srcNameActions
    dest = path.join cwd, @dest, @src
    log.v "copy: #{src} -> #{dest}"

    opts = {}
    if @copySpec.filters.length > 0
      noEOL = @opts.noEOL
      filters = @copySpec.filters
      opts.transform = ( rs, ws, file ) ->
        stream = rs
        filters.forEach ( f ) ->
          _f = ( line ) ->
            out = f line
            out += os.EOL unless noEOL
            out
          stream = stream.pipe(split _f)
        stream.pipe ws

    copyFile src, dest, opts

module.exports = CopyAction
    


