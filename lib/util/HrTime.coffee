pretty = require 'pretty-hrtime'
prop = require './prop'

class HrTime
  
  constructor : ( opts = {} ) ->
    @mark() unless opts.manual

  mark : =>
    if !@start
      @start = process.hrtime()
    else if !@end
      @end = process.hrtime @start
    else
      throw new Error "Both start/end already set"

  toString : =>
    pretty @end

module.exports = HrTime