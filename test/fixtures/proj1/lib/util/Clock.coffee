pretty = require 'pretty-hrtime'
prop = require './prop'

class Clock

  prop @, 'time', get : -> process.hrtime @start

  prop @, 'pretty', get : -> pretty @time

  constructor : () ->
    @start = process.hrtime()

module.exports = Clock