out = require('../util/out')
rek = require 'rekuire'
Script = rek 'Script2'

options = require 'yargs'
.usage 'kohi [options] tasks'
.options
    b :
      alias : 'build-file'
      describe : 'Specifies the build file'
    c :
      alias : 'settings-file'
      describe : 'Specifies the settings file'
    console :
      describe : 'Specifies which type of console output to generate'
      choices : [ 'plain', 'auto', 'rich' ]
      default : 'auto'
    continue :
      boolean : true
      default : false
      describe : 'Continues task execution after a task fail'
    d :
      alias : 'debug'
      describe : 'Log in debug mode'
    p :
      alias : 'project-dir'
      default : process.cwd()
      describe : 'Specifies the start directory. Defaults to the current' +
        ' directory.'
.help()
.argv

onError = (err) ->
  console.log "ERROR: #{err.message}"

s = new Script
  buildDir : options.projectDir,
  tasks : options._
  continueOnError : options.continue
s.initialize()
.then -> s.configure()
.then -> s.execute()
.then -> s.report()
.fail onError
