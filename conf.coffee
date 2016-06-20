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
      cacheDir : '.kohi'
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
      less :
        from :
          srcDir : '.'
          includes : [ 'less/**/*.less', 'assets/less/**/*.less' ]
      output :
        dir : buildDir
        coffeescript :
          dir : "#{buildDir}/js"
        less :
          dir : "#{buildDir}/public/css"
    test :
      'default' :
        dirs : [ 'test' ]
  plugins :
    coffeescript :
      uses : 'GulpCompilePlugin'
      gulpType : 'gulp-coffee'
      base: '.'
      options :
        bare : true
        header : false
    less :
      uses : 'GulpCompilePlugin'
      gulpType : 'gulp-less'

  module.exports =
    nconf : nconf
    get : ( key, def ) -> nconf.get(key) or def



