rek = require 'rekuire'
Promise = rek 'Promise'


class Action
  constructor : ( @f ) ->
    @isSandbox = @f?.type is 'function'

  doExec : =>
    if @exec? and @execSync?
      throw new Error "Only one of 'exec' or 'execSync' may be defined"
    return @execSync() if @execSync?
    return new Promise(@exec) if @exec?
    return @f() if @f #and !@f?.type is 'function'
    throw new Error "Don't know how to execute action"

module.exports = Action