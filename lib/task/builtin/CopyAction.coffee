Action = require '../Action'
path = require 'path'

class CopyAction extends Action
  constructor : ( @src, @dest, @opts ) ->

  exec : ( p ) =>
    cwd = @opts.cwd or process.cwd()
    src = path.join cwd, @src
    dest = path.join cwd, @dest
    console.log "copy: #{src} -> #{dest}"
    p.done()
    


