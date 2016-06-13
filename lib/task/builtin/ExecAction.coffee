Action = require '../Action'
out = require('../../util/out')
execFile = require('child_process').execFile

class ExecAction extends Action
  constructor : ( opts = {}) ->
    @spec = opts.spec
    super opts

  exec: ( resolve, reject ) =>
    opts = {}
    opts.env = @spec._env if @spec._env?
    opts.cwd = @spec._workingDir if @spec._workingDir?
    execFile @spec._executable, @spec._args, opts, ( e, stdout, stderr ) =>
      if e
        console.log e
        @spec.execResult = e
        unless @spec._ignoreExitValue
          return reject switch e.code
            when 'ENOENT' then new Error "#{e.cmd}: command not found"
            else
              e 
      @println stdout if stdout?
      @println stderr if stderr?
      resolve()

module.exports = ExecAction
    


