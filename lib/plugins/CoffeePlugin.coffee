rek = require 'rekuire'
Plugin = require './Plugin'
log = require('../util/logger') 'CoffeePlugin'
SourceSetContainer = require '../task/SourceSetContainer'
CopySpec = rek 'lib/task/builtin/CopySpec'
SourceSetOutput = rek 'lib/task/SourceSetOutput'
CoffeeOptions = require './coffeescript/CoffeeOptions'
CoffeeTask = require './coffeescript/CoffeeTask'
TaskFactory = rek 'lib/task/TaskFactory'

class CoffeePlugin extends Plugin
  constructor : ->
    log.v 'ctor()'

  apply : ( project ) =>
    return if @configured
    super project
    @options = new CoffeeOptions()
    project.extensions.add 'coffeescript', @options

    @_createSourceSets()

    TaskFactory.register 'CompileCoffee', ( x ) -> new CoffeeTask x
    project.task 'compileCoffee', type : 'CompileCoffee'
    #unless project.tasks.has

  _createSourceSets : =>
    unless @project.plugins.sourceSets?
      @project.apply plugin : 'sourceSets'

    root = @project.sourceSets
    unless root.has 'main'
      root.add 'main', new SourceSetContainer parent : root
    unless root.has 'test'
      root.add 'test', new SourceSetContainer parent : root

    main = root.get 'main'
    test = root.get 'test'

    unless main.has 'output'
      out = new SourceSetOutput parent : main
      out.dir = 'dist'
      main.add 'output', out

    unless main.has 'coffeescript'
      src = new CopySpec parent : main
      src.srcDir = 'lib'
      src.include '**/*.coffee'
      main.add 'coffeescript', src

    unless test.has 'coffeescript'
      src = new CopySpec parent : test
      src.include 'test/**/*.coffee'
      test.add 'coffeescript', test

module.exports = CoffeePlugin