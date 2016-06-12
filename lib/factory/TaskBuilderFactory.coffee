BaseFactory = require './BaseFactory'
util = require 'util'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
_ = require 'lodash'

class TaskBuilderFactory extends BaseFactory

  newInstance : ( builder, name, value, attr ) =>
    log.v 'newInstance', value, attr
    opts = _.extend {}, attr
    opts.name = value
    opts.project = @script.project
    @script.project.tasks.create opts

module.exports = TaskBuilderFactory