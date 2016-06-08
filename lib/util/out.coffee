C = require('colors/safe')
prop = require './prop'
os = require 'os'
ansiEscapes = require 'ansi-escapes'

stdout = process.stdout
print = ( s ) -> stdout.write s
println = ( s ) -> stdout.write s + os.EOL

colors = [ 'green', 'grey', 'white', 'red', 'yellow' ]
class Message

  prop @, 'string', get : -> @parts.join ''

  prop @, 'show', get : -> console.log @string

  constructor : ( msg ) ->
    @parts = []
    for c in colors
      @[ c ] = ( msg ) =>
        @parts.push C[ c ] msg
        @
    @grey msg if msg?

  msg : ( msg ) =>
    @grey msg
    @

  eolThen : ( msg ) =>
    @eol() if @parts.length
    @msg msg

  thenEol : ( msg ) =>
    @parts.push msg if msg?
    @eol()

  eol : =>
    println @string
    @parts = []
    @

  clear : =>
    @parts = []
    @

message = new Message()

progress = ( msg ) ->
  message.msg msg

for c in colors
  progress[ c ] = message[ c ]

progress.eol = message.eol
progress.eolThen = message.eolThen
progress.thenEol = message.thenEol

module.exports = progress