_ = require 'lodash'
rek = require 'rekuire'
Q = require 'q'
prop = rek 'prop'
BaseObject = rek 'BaseObject'

class Action extends BaseObject

  prop @, 'project', get : -> @task.project

  prop @, 'isSandbox', get : -> @f?.type is 'function'

  @_addProperties
    required : [ 'task' ]
    optional : [ 'f' ]

  _init : ( opts ) =>
    super opts

  println : ( msg ) =>
    @project.println msg

  doExec : =>
    if @exec? and @execSync?
      throw new Error "Only one of 'exec' or 'execSync' may be defined"

    promise = Q.Promise(@exec) if @exec?
    promise = Q(@execSync()) if @execSync?
    promise = Q(@f()) if @f

    if promise
      return promise
      .fail @addError

    return new Error "Don't know how to execute action"

module.exports = Action