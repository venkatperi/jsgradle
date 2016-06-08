Action = require '../Action'
log = require('../../util/logger') 'ExecAction'
out = require('../../util/out') 
execFile = require('child_process').execFile

class ExecAction extends Action
  constructor : ( @spec ) ->

  exec : ( p ) =>
    {resolve, reject} = p.async()
    opts = {}
    opts.env = @spec._env if @spec._env?
    opts.cwd = @spec._workingDir if @spec._workingDir?
    execFile @spec._executable, @spec._args, opts, ( e, stdout, stderr ) =>
      if e
        @spec.execResult = e
        unless @spec._ignoreExitValue
          return reject switch e.code
            when 'ENOENT' then new Error "#{e.cmd}: command not found"
      out.eolThen stdout if stdout?
      out.eolThen stderr if stderr?
      resolve()

module.exports = ExecAction
    


