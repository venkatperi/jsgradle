Action = require '../Action'
path = require 'path'

class CopyAction extends Action
  constructor : ( @src, @dest, @opts ) ->

  exec : =>
    cwd = @opts.cwd or process.cwd()
    src = if @src[0] is path.sep then @src else path.join cwd, @src
    dest = path.join cwd, @dest
    console.log "copy: #{src} -> #{dest}"

module.exports = CopyAction
    


