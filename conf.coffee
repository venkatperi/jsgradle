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
    cache :
      cacheDir : '.kohi/gulp-cache'
    build :
      buildDir : buildDir
      genDir : "#{buildDir}/gen"
      continueOnError : false
      version : '0.1.0'
  sourceSets :
    main :
      'default' :
        dirs : [ 'lib' ]
        includes : [ '' ]
        excludes : [ '' ]
      coffeescript :
        from :
          srcDir : '.'
          includes : [ 'index.coffee', 'lib/**/*.coffee' ]
      output :
        dir : buildDir
        coffeescript :
          dir : "#{buildDir}/js"
    test :
      'default' :
        dirs : [ 'test' ]
  plugins :
    coffeescript :
      uses : 'GulpCompilePlugin'
      gulpType : 'gulp-coffee'
      options :
        bare : true
        header : false

  module.exports =
    nconf : nconf
    get : ( key, def ) -> nconf.get(key) or def



