rek = require 'rekuire'
Q = require 'q'
prop = rek 'prop'

class Action

  prop @, 'project', get : -> @task.project

  constructor : ( {@f, @task} = {} ) ->
    @isSandbox = @f?.type is 'function'

  println : ( msg ) =>
    @project.println msg

  doExec : =>
    if @exec? and @execSync?
      throw new Error "Only one of 'exec' or 'execSync' may be defined"
    return @execSync() if @execSync?
    return Q.Promise(@exec) if @exec?
    return @f() if @f #and !@f?.type is 'function'
    throw new Error "Don't know how to execute action"

module.exports = Action