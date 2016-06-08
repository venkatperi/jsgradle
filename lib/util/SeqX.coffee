_ = require 'lodash'
seqx = require 'seqx'

class SeqX
  seq : ( f ) =>
    @_seqx ?= seqx()
    @_done = @_seqx.add f
    .fail ( err ) => @emit 'error', err

module.exports = SeqX