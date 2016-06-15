rek = require 'rekuire'
Task = require './Task'
FileSourceSet = require './FileSourceSet'
prop = rek 'prop'

class FileTask extends Task

  @_addProperties
    required : [ 'spec', 'actionType' ]
    optional : [ 'output', 'options' ]

  prop @, 'files', get : ->
    @_cache.get 'files', -> new FileSourceSet spec : @spec

  summary : =>
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    srcDir = @project.fileResolver.file @spec.srcDir
    outDir = @output?.dir or @spec.dest
    dest = @project.fileResolver.file outDir if outDir?

    @_configured.resolve(
      @files.resolve @project.fileResolver
      .then ( files ) =>
        for f in files
          @doLast new @actionType
            task : @,
            src : f,
            dest : dest,
            opts : @options,
            srcDir : srcDir,
            spec : @spec
    )

module.exports = FileTask