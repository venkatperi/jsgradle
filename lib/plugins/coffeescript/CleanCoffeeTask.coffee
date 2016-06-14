_ = require 'lodash'
rek = require 'rekuire'
RmdirTask = rek 'RmdirTask'

class CleanCoffeeTask extends RmdirTask

  init : ( opts = {} ) =>
    super _.extend opts,
      dirs : [ @project.sourceSets.get('main.output').dir ]

module.exports = CleanCoffeeTask