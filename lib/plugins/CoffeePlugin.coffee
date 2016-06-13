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
    project.apply plugin : 'build'
    
    @options = new CoffeeOptions()
    project.extensions.add 'coffeescript', @options
    @_createSourceSets()
    TaskFactory.register 'CompileCoffee', ( x ) -> new CoffeeTask x
    project.task 'compileCoffee', type : 'CompileCoffee'

    project.tasks.get('build').task.dependsOn 'compileCoffee'

  _createSourceSets : =>
    unless @project.plugins.sourceSets?
      @project.apply plugin : 'sourceSets'

    root = @project.sourceSets
    unless root.has 'main'
      root.add 'main', new SourceSetContainer parent : root, name : 'main'
    unless root.has 'test'
      root.add 'test', new SourceSetContainer parent : root, name : 'test'

    main = root.get 'main'
    test = root.get 'test'

    unless main.has 'output'
      out = new SourceSetOutput parent : main, name : 'output'
      out.dir = 'dist'
      main.add 'output', out

    unless main.has 'coffeescript'
      src = new CopySpec parent : main, name : 'coffeescript', allMethods : true
      src.srcDir = 'lib'
      src.include '**/*.coffee'
      main.add 'coffeescript', src

    unless test.has 'coffeescript'
      src = new CopySpec parent : test, name : 'coffeescript'
      src.include 'test/**/*.coffee'
      test.add 'coffeescript', src

module.exports = CoffeePlugin