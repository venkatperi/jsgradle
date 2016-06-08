Plugin = require './Plugin'
log = require('../util/logger') 'CoffeePlugin'
SourceSetContainer = require '../task/SourceSetContainer'
SourceSet = require '../task/FileSourceSet'

class CoffeePlugin extends Plugin
  constructor : ->
    log.v 'ctor()'
    @options =
      bare : false
      sourceMap : false
      literate : false

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'coffeescript', @options

    @_createSourceSets()

    project.task 'compileCoffee', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>

  _createSourceSets : =>
    root = @project._sourceSets
    unless root.has 'main'
      root.add 'main', new SourceSetContainer()
    unless root.has 'test'
      root.add 'test', new SourceSetContainer()

    main = root.get 'main'
    test = root.get 'test'
    unless main.has 'coffeescript'
      main.add 'coffeescript', new SourceSet()
    unless test.has 'coffeescript'
      test.add 'coffeescript', new SourceSet()

module.exports = CoffeePlugin