var Q, execFile;

Q = require('q');

execFile = require('child_process').execFile;


/*
  * `cmd` {String} The executable 
  * `args` {Array} optional arguments 
  * `opts` {Object} options 
    * `cwd` {String} current dir 
    * `env` {Object} environment variables
 */

module.exports = function(cmd, args, opts) {
  if (args == null) {
    args = [];
  }
  if (opts == null) {
    opts = {};
  }
  return new Q.promise(function(resolve, reject) {
    return execFile(cmd, args, opts, function(e, stdout, stderr) {
      if (e) {
        if (!this.spec._ignoreExitValue) {
          return reject((function() {
            switch (e.code) {
              case 'ENOENT':
                return new Error(cmd + ": command not found");
              default:
                return e;
            }
          })());
        }
      }
      return resolve({
        stdout: stdout,
        stderr: stderr
      });
    });
  });
};
