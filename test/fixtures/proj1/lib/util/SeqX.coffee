seqx = require 'seqx'

class SeqX
  _seq : ( task ) =>
    @_seqx ?= seqx()
    @_done = @_seqx.add.apply @_seqx, arguments
    .fail ( err ) => @emit 'error', err

module.exports = SeqX