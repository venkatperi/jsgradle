_ = require 'lodash'
rek = require 'rekuire'
Plugin = require './Plugin'
SourceSetContainer = rek 'SourceSetContainer'
CopySpec = rek 'CopySpec'
SourceSetOutput = rek 'SourceSetOutput'
CoffeeOptions = rek 'CoffeeOptions'
CleanMainOutputTask = rek 'CleanMainOutputTask'
TaskFactory = rek 'TaskFactory'
CoffeeConvention = rek 'CoffeeConvention'
GulpTask = rek 'GulpTask'

coffeeTask = ( project ) -> ( opts = {} ) ->

  options = project.extensions.get 'coffeescript'
  output = project.sourceSets.get('main.output').dir
  spec = project.sourceSets.get 'main.coffeescript'
  
  _opts = _.extend {}, opts
  _.extend _opts,
    options : options,
    gulpType : 'gulp-coffee'
    output : output
    spec : spec
  new GulpTask _opts

class CoffeePlugin extends Plugin

  doApply : =>
    @applyPlugin 'build'
    @applyPlugin 'sourceSets'

    @register
      extensions :
        coffeescript : CoffeeOptions @project.callScriptMethod
      conventions :
        coffeescript : CoffeeConvention
      taskFactory :
        CompileCoffee : coffeeTask @project
        CleanCoffee : CleanMainOutputTask

    @createTask 'compileCoffee', type : 'CompileCoffee'
    @createTask 'cleanCoffee', type : 'CleanCoffee'
    @task('build').dependsOn 'compileCoffee'
    @task('clean').dependsOn 'cleanCoffee'

module.exports = CoffeePlugin