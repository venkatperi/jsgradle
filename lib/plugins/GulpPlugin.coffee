rek = require 'rekuire'
Plugin = require './Plugin'
GulpTask = rek 'GulpTask'

class GulpPlugin extends Plugin

  doApply : =>
    @register
      taskFactory :
        GulpCoffee : GulpTask

module.exports = GulpPlugin