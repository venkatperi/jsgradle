Task = require './Task'
FileSourceSet = require './FileSourceSet'

class FileTask extends Task

  init : ( opts ) =>
    @output = opts.output if opts.output
    @options = opts.options or {}
    @spec = opts.spec
    @actionType = opts.actionType
    @files = new FileSourceSet spec : @spec
    super opts
    
  summary: =>
    if @didWork then "#{@didWork} file(s) OK" else "UP-TO-DATE"

  onAfterEvaluate : =>
    srcDir = @project.fileResolver.file @spec.srcDir
    outDir = if @output then @output.dir else @spec.dest
    dest = @project.fileResolver.file outDir if outDir?
    @_configured.resolve(
      @files.resolve @project.fileResolver
      .then ( files ) =>
        for f in files
          @doLast new @actionType
            task : @, src : f, dest : dest, 
            opts : @options, srcDir : srcDir, 
            spec : @spec
    )

module.exports = FileTask