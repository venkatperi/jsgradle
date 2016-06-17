rek = require 'rekuire'
Task = require '../Task'
ExecAction = require './ExecAction'

class ExecTask extends Task

  @_addProperties
    exportedMethods : [ 'args', 'commandLine',
      'executable', 'environment', 'ignoreExitValue',
      'workingDir', ]

  args : ( arg... ) =>
    @_args = @_args.concat arg

  commandLine : ( line ) =>
    if typeof line is 'string'
      @_args = line.split(' ')
    else if Array.isArray line
      @_args = line
    @_executable = @_args.shift()

  executable : ( name ) =>
    @_executable = name

  environment : ( env ) =>
    @_env ?= {}
    @_env[ k ] = v for own k,v of env

  ignoreExitValue : ( val ) =>
    @_ignoreExitValue = val

  workingDir : ( dir ) =>
    @_workingDir = dir

  onAfterEvaluate : =>
    unless @_executable?
      throw new Error "No executable specified"
    @doFirst new ExecAction spec : @, task : @

module.exports = ExecTask