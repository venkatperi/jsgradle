assert = require 'assert'
prop = require './../util/prop'
out = require './../util/out'
log = require('../util/logger') 'TaskInfo'
SeqX = require '../util/SeqX'
{multi} = require 'heterarchy'
{EventEmitter} = require 'events'
Clock = require '../util/Clock'

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

class TaskInfo extends multi EventEmitter, SeqX
  #@STATE : STATE

  prop @, 'name', get : -> @task.name

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
    @configurators = []
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

  configure : ( p, runp ) =>
    clock = new Clock()
    log.v tag = "configuring #{@task.path}"
    task = @task
    #@seq => runp @task.configure, [ @task ], [ @task ]
    @configurators.forEach ( c ) =>
      @seq -> task.configure c, runp

    @seq -> log.v tag, 'done:', clock.pretty

  afterEvaluate : ( p, runp ) =>
    clock = new Clock()
    tag = "onAfterEvaluate #{@task.path}"
    log.v tag
    task = @task
    @seq -> runp task.afterEvaluate, [], [ task ]
    task.actions.forEach ( a ) =>
      if a.afterEvaluate?
        @seq -> runp a.onAfterEvaluate, [], [ task ]
    @seq -> log.v tag, 'done:', clock.pretty

  execute : ( p, runp ) =>
    log.v tag = "executing #{@task.path}"
    clock = new Clock()
    task = @task
    @seq => out.grey @task.path
    task.actions.forEach ( a ) =>
      @seq =>
        runp a.exec, [], [ task ]
        .fail ( err ) =>
          @errors ?= []
          @errors.push err
          out.yellow(' FAILED').eol()
          out(err.message).eol()
    @seq =>
      log.v tag, 'done: ', clock.pretty

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

  toString : => "TaskInfo(#{@task.toString()})"

module.exports = TaskInfo
  