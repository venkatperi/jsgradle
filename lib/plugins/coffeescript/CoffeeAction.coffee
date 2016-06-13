path = require 'path'
rek = require 'rekuire'
Action = rek 'Action'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
coffeeScript = require 'coffee-script'
{readFile, writeFileMkdir, changeExt} = rek 'fileOps'

class CoffeeAction extends Action
  constructor : ( {@src, @dest, @opts, @srcDir, @spec} ) ->
    super()

  execSync :  =>
    rel = path.relative @srcDir, @src
    dest = path.join @dest, @spec.srcDir, rel
    dest = changeExt dest, @opts.ext or '.js'
    log.v "#{rel} -> #{dest}"

    readFile @src, 'utf8'
    .then ( source ) =>
      js = coffeeScript.compile source, @opts
      writeFileMkdir dest, js

module.exports = CoffeeAction
    


