Q = require 'q'
HrTime = require './HrTime'

time = ( f, args... ) ->
  t = new HrTime()
  Q.try -> f.apply null, args...
  .then ( res ) ->
    t.mark()
    [ res, t ]

module.exports = time
    
