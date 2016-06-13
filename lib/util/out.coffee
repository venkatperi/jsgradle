C = require('colors/safe')
prop = require './prop'
os = require 'os'

stdout = process.stdout
print = ( s ) -> stdout.write s
println = ( s ) -> 
  console.log s
  #stdout.write s + os.EOL
  #stdout.flush()

colors = [ 'green', 'grey', 'white', 'red', 'yellow' ]
class Message

  prop @, 'string', get : -> @parts.join ''

  prop @, 'show', get : -> console.log @string

  constructor : ( msg ) ->
    @parts = []
    colors.forEach (c) =>
      @[ c ] = ( msg ) =>
        @parts.push C[ c ] msg
        @
    @grey msg if msg?

  msg : ( msg ) =>
    @grey msg
    #@parts.push msg
    @

  eolThen : ( msg ) =>
    @eol() if @parts.length
    @msg msg

  thenEol : ( msg ) =>
    @parts.push msg if msg?
    @eol()
    
  ifNewline: (msg) =>
    unless @parts.length
      @msg msg
    @

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
progress.ifNewline = message.ifNewline
progress.error = message.red

module.exports = progress