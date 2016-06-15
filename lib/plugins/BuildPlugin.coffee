Plugin = require './Plugin'

class BuildsPlugin extends Plugin

  doApply : =>
    @createTask 'build'
    @createTask 'clean'
    @project.defaultTasks 'build'
    @task('clean').enabled = false
    @task('build').dependsOn 'clean'

module.exports = BuildsPlugin