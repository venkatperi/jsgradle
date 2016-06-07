pretty = require 'pretty-hrtime'

class Clock
  constructor : () ->
    @start = process.hrtime()

  time : => process.hrtime @start

  pretty : => pretty @time()

module.exports = Clock