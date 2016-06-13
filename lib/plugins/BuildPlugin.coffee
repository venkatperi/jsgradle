Plugin = require './Plugin'
rek = require 'rekuire'

class BuildsPlugin extends Plugin
  apply : ( project ) =>
    return if @configured
    super project
    project.task 'build'
    project.defaultTasks 'build'

module.exports = BuildsPlugin