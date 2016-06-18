_ = require 'lodash'
rek = require 'rekuire'
Task = rek 'lib/task/Task'
FileSourceSet = rek 'FileSourceSet'
prop = rek 'prop'
CompileCoffeeAction = require './CompileCoffeeAction'
FileTask = rek 'FileTask'
log = rek('logger')(require('path').basename(__filename).split('.')[0])

class CompileCoffeeTask extends FileTask

  init : ( opts = {} ) =>
    opts = _.extend opts,
      spec : @project.sourceSets.get 'main.coffeescript'
      options : @project.extensions.get 'coffeescript'
      output : @project.sourceSets.get 'main.output.coffeescript'
      actionType : CompileCoffeeAction
    super opts

module.exports = CompileCoffeeTask