_ = require 'lodash'
rek = require 'rekuire'
Task = rek 'Task'
FileSourceSet = rek 'FileSourceSet'
prop = rek 'prop'
CoffeeAction = require './CoffeeAction'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class CoffeeTask extends Task

  prop @, 'spec',
    get : -> @project.sourceSets.get 'main.coffeescript'

  prop @, 'output',
    get : -> @project.sourceSets.get 'main.output'

  prop @, 'options',
    get : -> @project.extensions.get 'coffeescript'

  constructor : ( opts = {} )->
    opts.type = 'Coffee'
    super opts
    @files = new FileSourceSet spec : @spec

  onAfterEvaluate : =>
    log.v 'onAfterEvaluate'
    srcDir = @project.fileResolver.file @spec.srcDir
    dest = @project.fileResolver.file @output.dir
    @_configured.resolve(
      @files.resolve @project.fileResolver
      .then ( files ) =>
        for f in files
          @doLast new CoffeeAction
            src : f, dest : dest, opts : @options,
            srcDir : srcDir, spec : @spec
    )

module.exports = CoffeeTask