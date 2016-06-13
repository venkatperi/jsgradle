_ = require 'lodash'
rek = require 'rekuire'
Task = rek 'lib/task/Task'
FileSourceSet = rek 'FileSourceSet'
prop = rek 'prop'
CoffeeAction = require './CoffeeAction'
FileTask = rek 'FileTask'

class CoffeeTask extends FileTask

  init : ( opts = {} ) =>
    opts = _.extend opts,
      spec : @project.sourceSets.get 'main.coffeescript'
      options : @project.extensions.get 'coffeescript'
      output : @project.sourceSets.get 'main.output'
      actionType : CoffeeAction
    super opts

module.exports = CoffeeTask