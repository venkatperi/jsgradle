Q = require 'q'
rek = require 'rekuire'
GulpThrough = rek 'GulpThrough'

class CountFiles extends GulpThrough
  constructor : ( opts ) ->
    super opts
    @count = 0

  onData : ( f, e ) =>
    @count++
    super f, e

  onDone : =>
    @emit 'count', @count
    super()

module.exports = CountFiles
    
