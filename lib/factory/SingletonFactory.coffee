BaseFactory = require './BaseFactory'

class GreetingFactory extends BaseFactory
  constructor : ( @obj ) ->

  newInstance : ( builder, name, value, args ) =>
    @obj
    
module.exports = GreetingFactory