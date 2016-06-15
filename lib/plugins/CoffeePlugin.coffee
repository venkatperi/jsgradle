rek = require 'rekuire'
Plugin = require './Plugin'
log = require('../util/logger') 'CoffeePlugin'
SourceSetContainer = require '../task/SourceSetContainer'
CopySpec = rek 'lib/task/builtin/CopySpec'
SourceSetOutput = rek 'lib/task/SourceSetOutput'
CoffeeOptions = require './coffeescript/CoffeeOptions'
CompileCoffeeTask = require './coffeescript/CompileCoffeeTask'
CleanCoffeeTask = require './coffeescript/CleanCoffeeTask'
TaskFactory = rek 'lib/task/TaskFactory'
CoffeeConvention = require './coffeescript/CoffeeConvention'

class CoffeePlugin extends Plugin

  apply : ( project ) =>
    return if @configured
    super project
    project.apply plugin : 'build'

    project.extensions.add 'coffeescript', new CoffeeOptions() 
    project.conventions.add 'coffeescript', new CoffeeConvention()
    
    TaskFactory.register 'CompileCoffee', ( x ) -> new CompileCoffeeTask x
    TaskFactory.register 'CleanCoffee', ( x ) -> new CleanCoffeeTask x
    project.task 'compileCoffee', type : 'CompileCoffee'
    project.task 'cleanCoffee', type : 'CleanCoffee'
    project.tasks.get('build').task.dependsOn 'compileCoffee'
    project.tasks.get('clean').task.dependsOn 'cleanCoffee'

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