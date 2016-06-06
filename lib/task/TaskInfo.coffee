assert = require 'assert'
Task = require './Task'
prop = require './../util/prop'

STATE = {
  Unknown : 'Unknown',
  NotRequired : 'NotRequired',
  ShouldRun : 'ShouldRun',
  MustRun : 'MustRun',
  MustNotRun : 'MustNotRun',
  Executing : 'Executing',
  Executed : 'Executed',
  Skipped : 'Skipped'
}

class TaskInfo
  #@STATE : STATE

  prop @, 'isRequired', get : -> @state is STATE.ShouldRun

  prop @, 'isMustNotRun', get : -> @state is STATE.MustNotRun

  prop @, 'isIncludeInGraph',
    get : -> @state in [ STATE.NotRequired, STATE.Unknown ]

  prop @, 'isReady',
    get : -> @state in [ STATE.ShouldRun, STATE.MustRun ]

  prop @, 'isInKnownState', get : -> @state isnt STATE.Unknown

  prop @, 'isComplete',
    get : -> @state in [
      STATE.Executed,
      STATE.Skipped,
      STATE.Unknown,
      STATE.NotRequired,
      STATE.MustNotRun ]

  prop @, 'isSuccessful',
    get : -> @state in [ STATE.ShouldRun, STATE.MustRun ] or
      (state is STATE.Executed and !!isFailed)

  prop @, 'isFailed',
    get : -> @taskFailure? or @_executionFailure?

  prop @, 'taskFailure',
    get : -> @task.state.failure

  constructor : ( @task, opts ) ->
    @state = STATE.Unknown
    @configurator = undefined
    @dependencyPredecessors = new Set()
    @dependencySuccessors = new Set()
    @mustSuccessors = new Set()
    @shouldSuccessors = new Set()
    @finalizers = new Set()
    @dependenciesProcessed = false
    @dependsOn = []
    if opts.dependsOn
      deps = opts.dependsOn
      deps = [ deps ] unless Array.isArray deps
      for d in deps
        d = d()[ 0 ] if d if typeof d is 'function'
        @dependsOn.push d


  configure : =>
    @configurator @task if @configurator?

  execute : (run) =>
    #@startExecution()
    for a in @task.actions
      run a, @task
  #@finishExecution()

  startExecution : =>
    assert @isReady
    @state = STATE.Executing

  finishExecution : =>
    assert @state is STATE.Executing
    @state = STATE.Executed

  skipExecution : =>
    assert @state is STATE.ShouldRun
    @state = STATE.Skipped

  require : => @state = STATE.ShouldRun

  doNotRequire : => @state = STATE.NotRequired

  mustNotRun : => @state = STATE.MustNotRun

  enforceRun : =>
    assert @state in [ STATE.ShouldRun, STATE.MustNotRun, STATE.MustRun ]
    @state = STATE.MustRun

  executionFailure : ( f ) =>
    return @_executionFailure if arguments.length is 0
    @_executionFailure = f
    @state = STATE.Executing

  allDependenciesComplete : =>
    for s in [ @mustSuccessors, @dependencySuccessors ]
      i = s.values()
      while (v = i.next(); !v.done)
        return false if !v.value.isComplete
    true

  allDependenciesSuccessful : =>
    i = @dependencySuccessors.values()
    while (v = i.next(); !v.done)
      return false if !v.value.isSuccessful
    true

  addDependencySuccessor : ( to ) =>
    @dependencySuccessors.add to
    to.dependencyPredecessors.add @

  addMustSuccessor : ( n ) => @mustSuccessors.add n

  addFinalizer : ( n ) => @finalizers.add n

  addShouldSuccessor : ( n ) => @shouldSuccessors.add n

  removeShouldRunAfterSuccessor : ( n ) => @shouldSuccessors.delete n

  toString: => "TaskInfo(#{@task.toString()})"

module.exports = TaskInfo
  