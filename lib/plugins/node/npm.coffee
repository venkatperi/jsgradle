npm = require 'npm'
{EventEmitter} = require 'events'
npmlog = require 'npmlog'
rek = require 'rekuire'
exec = rek 'lib/util/exec'

class Npm extends EventEmitter

  cmd : ( name, args... ) =>
    conf = {}
    npm.load conf, ( err ) =>
      console.log err
      npm.commands[ name ] args...

  list : =>
    conf = {}
    npm.load conf, ( err ) =>
      console.log err if err?
      ls = require 'npm/lib/ls'
      ls [], true, ( err, res ) ->
        console.log err if err?
        console.log res if res?

  install : ( pkg ) =>
    conf = {}
    npm.load conf, ( err ) =>
      console.log err if err?
      install = require 'npm/lib/install'
      install.Installer.prototype.printInstalled = ( cb ) =>
        console.log 'in print installed'
        cb()
      install null, [ pkg ], ( err, res ) ->
        console.log err if err?
        console.log res if res?

#new Npm().list()
#new Npm().install('test')

exec '/usr/local/bin/npm', [ 'install', 'test', '--save' ]
.then ( res ) ->
  console.log res
