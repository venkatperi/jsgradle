Action = require '../Action'
log = require('../../util/logger') 'ExecAction'
execFile = require('child_process').execFile

class ExecAction extends Action
  constructor : ( @spec ) ->

  exec : ( p ) =>
    {resolve, reject} = p.async()
    opts = {}
    opts.env = @spec._env if @spec._env?
    opts.cwd = @spec._workingDir if @spec._workingDir?
    execFile @spec._executable, @spec._args, opts, ( e, out, err ) =>
      if e
        @spec.execResult = e
        return reject e unless @spec._ignoreExitValue
      console.log out if out?
      console.log err if err?
      resolve()

module.exports = ExecAction
    


