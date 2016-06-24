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
      babel :
        from :
          srcDir : '.'
          includes : [ 'index.js', '{src,lib}/**/*.js' ]
      coffeescript :
        from :
          srcDir : '.'
          includes : [ 'index.coffee', '{src,lib}/**/*.coffee' ]
      sass :
        from :
          srcDir : '.'
          includes : [ 'src/style/**/*.scss' ]
      less :
        from :
          srcDir : '.'
          includes : [ 'src/style/**/*.less' ]
      output :
        dir : buildDir
        coffeescript :
          dir : "#{buildDir}/js"
        babel :
          dir : "#{buildDir}/js"
        sass :
          dir : "#{buildDir}/public/style"
        less :
          dir : "#{buildDir}/public/style"
    test :
      'default' :
        dirs : [ 'test' ]
  plugins :
    coffeescript :
      uses : 'GulpCompilePlugin'
      package : 'gulp-coffee'
      base : '.'
      options :
        bare : true
        header : false
    babel :
      uses : 'GulpCompilePlugin'
      package : 'gulp-babel'
      options :
        presets : [ 'es2015' ]
    sass :
      uses : 'GulpCompilePlugin'
      package : 'gulp-sass'
      options :
        style : 'compressed'
    less :
      uses : 'GulpCompilePlugin'
      package : 'gulp-less'

module.exports =
  nconf : nconf
  get : ( key, def ) -> nconf.get(key) or def



