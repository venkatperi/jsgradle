Q = require 'q'
execFile = require('child_process').execFile

###
  * `cmd` {String} The executable 
  * `args` {Array} optional arguments 
  * `opts` {Object} options 
    * `cwd` {String} current dir 
    * `env` {Object} environment variables
###
module.exports = ( cmd, args = [], opts = {} ) ->
  new Q.promise ( resolve, reject ) ->
    execFile cmd, args, opts, ( e, stdout, stderr ) ->
      if e
        unless @spec._ignoreExitValue
          return reject switch e.code
            when 'ENOENT' then new Error "#{cmd}: command not found"
            else
              e
      resolve stdout : stdout, stderr : stderr
