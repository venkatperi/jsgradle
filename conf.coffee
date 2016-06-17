path = require 'path'
nconf = require 'nconf'

nconf.file file : path.join process.env.HOME, '.kohi', 'settings.kohi'
nconf.file file : path.join __dirname, 'settings.kohi'

buildDir = 'build'

nconf.defaults
  script :
    build :
      dir : process.cwd()
      file : 'build.kohi'
      enc : 'utf8'
  project :
    startup :
      plugins : [ 'node' ]
    build :
      buildDir : buildDir
      continueOnError : false
      version : '0.1.0'
  convention :
    main :
      dirs : [ 'lib' ]
    test :
      dirs : [ 'test' ]
    output :
      dir : buildDir
    coffeescript :
      output :
        dir : "#{buildDir}/js"
  plugin :
    coffeescript :
      options :
        bare : true
        header : false

  module.exports =
    nconf : nconf
    get : ( key, def ) -> nconf.get(key) or def



