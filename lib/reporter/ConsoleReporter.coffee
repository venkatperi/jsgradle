rek = require 'rekuire'
out = rek 'out'

Reporter = require './Reporter'

class ConsoleReporter extends Reporter

  onScriptConfigureStart : ( script ) =>
    out.eolThen 'Configuring... '

  onScriptConfigureEnd : ( script, time ) =>
    unless script.failed
      out.ifNewline("> Configuring...")
      .grey(" #{time}").eol()

  onScriptAfterEvaluateStart : ( script ) =>
    out.eolThen 'After evaluate... '

  onScriptAfterEvaluateEnd : ( script, time ) =>
    out.ifNewline("> After evaluate...")
    .grey(" #{time}").eol()

  onProjectAfterEvaluateEnd : ( project, names ) =>
    if project.failed
      out.eolThen().white 'The following tasks failed in `afterEvaluate`'
      project.failedTasks.forEach ( t ) ->
        out.eolThen("#{t.displayName}")
        .red(" #{t.task.summary()} ")
        .eol()

  onProjectExecuteStart : ( project ) =>
    names = project.taskQueueNames
    out.grey "Executing #{names.length} task(s): #{names.join ', '}"

  onTaskExecuteStart : ( task ) =>
    out.eolThen task.displayName

  onTaskExecuteEnd : ( task, time ) =>
    if !task.failed
      out.ifNewline("> #{task.displayName}")
      .green(" #{task.summary()} ")
      .grey(time).eol()
    else
      out.ifNewline("> #{task.displayName}")
      .red(" #{task.summary()} ")
      .eol()

module.exports = ConsoleReporter