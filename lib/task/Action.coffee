_ = require 'lodash'
rek = require 'rekuire'
Q = require 'q'
prop = rek 'prop'
{ensureOptions} = rek 'validate'

class Action

  prop @, 'project', get : -> @task.project

  prop @, 'failed', get : -> @errors?.length > 0

  prop @, 'messages', get : -> _.map @errors, ( x ) -> x.message

  constructor : ( opts = {} ) ->
    {@task} = ensureOptions opts, 'task'
    @f = opts.f
    @isSandbox = @f?.type is 'function'
    @errors = []
    @init opts

  init : =>

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
      .fail ( err ) =>
        @errors ?= []
        @errors.push err
        throw err

    throw new Error "Don't know how to execute action"

module.exports = Action