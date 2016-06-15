rek = require 'rekuire'
Plugin = require './Plugin'
GulpTask = require './gulp/GulpTask'
TaskFactory = rek 'lib/task/TaskFactory'

class GulpPlugin extends Plugin

  apply : ( project ) =>
    return if @configured
    super project

    TaskFactory.register 'Gulp', ( x ) -> new GulpTask x

module.exports = GulpPlugin