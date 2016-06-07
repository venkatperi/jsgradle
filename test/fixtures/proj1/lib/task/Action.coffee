class Action
  constructor : ( @f, @isAsync = true ) ->

  exec : ( p ) => @f(p)

module.exports = Action