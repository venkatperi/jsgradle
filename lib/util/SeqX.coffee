_ = require 'lodash'
seqx = require 'seqx'

class SeqX
  seq : ( f ) =>
    @_seqx ?= seqx()
    @_done = @_seqx.add f
    .fail ( err ) =>
      throw err
      #@emit 'error', err
      @errors ?= []
      @errors.push err

module.exports = SeqX