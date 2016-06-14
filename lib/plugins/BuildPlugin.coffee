Plugin = require './Plugin'
rek = require 'rekuire'

class BuildsPlugin extends Plugin
  apply : ( project ) =>
    return if @configured
    super project
    project.task 'build'
    project.task 'clean'
    project.defaultTasks 'build'
    project.tasks.get('clean').task.enabled = false
    project.tasks.get('build').task.dependsOn 'clean'

module.exports = BuildsPlugin