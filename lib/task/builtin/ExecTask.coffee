Task = require '../Task'
ExecAction = require './ExecAction'

class ExecTask extends Task

  constructor : ( opts = {} )->
    opts.type = 'Exec'
    super opts
    @_args = []

    @actions.push new ExecAction @

  args : ( arg... ) =>
    @_args = @_arg.concat arg

  commandLine : ( line ) =>
    if typeof line is 'string'
      @_args = line.split(' ')
    else if Array.isArray line
      @_args = line
    @_executable = @_args.shift()

  executable : ( name ) => @_executable = name

  environment : ( env ) =>
    @_env ?= {}
    @_env[ k ] = v for own k,v of env

  ignoreExitValue : ( val ) =>
    @_ignoreExitValue = val

  workingDir : ( dir ) => @_workingDir = dir

  onAfterEvaluate : =>
    unless @_executable?
      throw new Error "No executable specified"


module.exports = ExecTask