_ = require 'lodash'
BaseFactory = require './BaseFactory'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
Project = rek 'lib/project/Project'

class ProjectFactory extends BaseFactory

  newInstance : ( builder, name, value, args ) =>
    opts = _.extend {}, args
    opts.name = value
    opts.script = @script
    proj = new Project opts
    @script.project = proj
    @script.listenTo proj
    proj

module.exports = ProjectFactory