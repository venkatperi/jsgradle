path = require 'path'
nconf = require 'nconf'

nconf.file file : path.join process.env.HOME, '.kohi', 'settings.kohi'
nconf.file file : path.join __dirname, 'settings.kohi'

nconf.defaults
  script :
    build :
      dir : process.cwd()
      file : 'build.kohi'
      enc : 'utf8'
  project :
    build :
      continueOnError : false
      version : '0.1.0'

module.exports =
  nconf : nconf
  get : ( key ) -> nconf.get key



