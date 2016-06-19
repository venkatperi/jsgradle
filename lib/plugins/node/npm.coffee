npm = require 'npm'
{EventEmitter} = require 'events'

class Npm extends EventEmitter

  cmd : ( name, args...) =>
    conf = {}
    npm.load conf, (err) =>
      console.log err
      npm.commands[ name ] args...
    
  list : =>
    conf = {}
    npm.load conf, (err) =>
      console.log err if err?
      ls = require 'npm/lib/ls'
      ls [], true, (err, res) ->
        console.log err, res

  install : ( pkg ) =>
    npm


new Npm().list()