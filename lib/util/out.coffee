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
    @color = 'grey'
    @parts = []
    colors.forEach ( c ) =>
      @[ c ] = ( msg ) =>
        if msg
          @parts.push C[ c ] msg
        else
          @color = c
        @
    @grey msg if msg?

  msg : ( msg ) =>
    @[ @color ] msg if msg?
    @

  eolThen : ( msg ) =>
    @eol() if @parts.length
    @msg msg if msg?
    @

  thenEol : ( msg ) =>
    @parts.push msg if msg?
    @eol()

  ifNewline : ( msg ) =>
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

  continue : ( prefix, msg ) =>
    @ifNewline("> #{prefix}")
    .msg(" #{@task.summary()} ")

  warning : ( msg ) =>
    @eolThen()
    .yellow msg
    .eol()

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
progress.warning = message.warning

module.exports = progress