Task = require './Task'
FileSourceSet = require './FileSourceSet'

class FileTask extends Task

  constructor : ( opts ) ->
    super opts
    @init opts

  init : ( opts ) =>
    @output = opts.output if opts.output
    @options = opts.options or {}
    @spec = opts.spec
    @actionType = opts.actionType
    @files = new FileSourceSet spec : @spec

  onAfterEvaluate : =>
    srcDir = @project.fileResolver.file @spec.srcDir
    outDir = if @output then @output.dir else @spec.dest
    dest = @project.fileResolver.file outDir if outDir?
    @_configured.resolve(
      @files.resolve @project.fileResolver
      .then ( files ) =>
        for f in files
          @doLast new @actionType
            src : f, dest : dest, opts : @options,
            srcDir : srcDir, spec : @spec
    )

module.exports = FileTask