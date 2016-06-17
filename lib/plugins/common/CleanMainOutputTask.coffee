rek = require 'rekuire'
RmdirTask = rek 'RmdirTask'
log = rek('logger')(require('path').basename(__filename).split('.')[0])


class CleanMainOutputTask extends RmdirTask

  onAfterEvaluate : =>
    @dirs ?= [ @project.sourceSets.get('main.output').dir ]

module.exports = CleanMainOutputTask