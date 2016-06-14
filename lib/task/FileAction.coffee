path = require 'path'
rek = require 'rekuire'
Action = rek 'Action'
{readFile, writeFileMkdir, changeExt} = rek 'fileOps'

class FileAction extends Action

  constructor : ( opts = {} ) ->
    for f in [ 'transform', 'src', 'dest', 'opts', 'srcDir', 'ext',
      'spec' ] when opts[ f ]
      @[ f ] = opts[ f ]
      delete opts[ f ]
    super opts

  execSync : =>
    rel = path.relative @srcDir, @src
    dest = path.join @dest, @spec.srcDir, rel
    dest = changeExt dest, @ext if @ext?

    readFile @src, 'utf8'
    .then ( source ) =>
      if @transform
        output = @transform source, @opts
      else
        output = source
      @task.didWork++
      writeFileMkdir dest, output

module.exports = FileAction
    


