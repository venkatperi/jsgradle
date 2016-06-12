rek = require 'rekuire'
Plugin = require './Plugin'
log = require('../util/logger') 'CoffeePlugin'
SourceSetContainer = require '../task/SourceSetContainer'
SourceSpec = rek 'lib/task/SourceSpec'

class CoffeeOptions
  constructor : ->
    @bare = false
    @sourceMap = false
    @literate = false

  hasProperty : ( name ) =>
    name in [ 'bare', 'sourceMap', 'literate' ]

class CoffeePlugin extends Plugin
  constructor : ->
    log.v 'ctor()'

  apply : ( project ) =>
    return if @configured
    super project
    @options = new CoffeeOptions()
    project.extensions.add 'coffeescript', @options

    @_createSourceSets()

    project.task 'compileCoffee', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>

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
    unless main.has 'coffeescript'
      src = new SourceSpec parent : main
      src.include 'lib/**/*.coffee'
      src.include 'src/**/*.coffee'
      src.include '*.coffee'
      main.add 'coffeescript', src
      
    unless test.has 'coffeescript'
      src = new SourceSpec parent : test
      src.include 'test/**/*.coffee'
      test.add 'coffeescript', test 

module.exports = CoffeePlugin