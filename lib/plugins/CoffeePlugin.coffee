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

coffeeTask = ( options ) -> ( opts = {} ) ->
  _opts = _.extend {}, opts
  _.extend _opts, options : options
  new GulpTask _opts

class CoffeePlugin extends Plugin

  doApply : =>
    @applyPlugin 'build'

    @register
      extensions :
        coffeescript : CoffeeOptions
      conventions :
        coffeescript : CoffeeConvention
      taskFactory :
        CompileCoffee : coffeeTask(@extension 'coffeescript')
        CleanCoffee : CleanMainOutput

    @createTask 'compileCoffee', type : 'GulpCoffee'
    @createTask 'cleanCoffee', type : 'CleanMainOutput'
    @task('build').dependsOn 'compileCoffee'
    @task('clean').task.dependsOn 'cleanCoffee'

module.exports = CoffeePlugin