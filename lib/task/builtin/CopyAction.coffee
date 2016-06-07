Action = require '../Action'
path = require 'path'
log = require('../../util/logger') 'CopyAction'
{copyFile} = require '../../util/fileOps'

class CopyAction extends Action
  constructor : ( @src, @dest, @opts ) ->

  exec : =>
    cwd = @opts.cwd or process.cwd()
    src = if @src[ 0 ] is path.sep then @src else path.join cwd, @src
    dest = path.join cwd, @dest, @src
    log.v "copy: #{src} -> #{dest}"

    copyFile src, dest

module.exports = CopyAction
    


