BaseFactory = require './BaseFactory'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
TargetSpec = rek 'TargetSpec'

class TargetSpecFactory extends BaseFactory

  newInstance : ( builder, name, value, args ) =>
    log.v 'newInstance'
    new TargetSpec dir : value

module.exports = TargetSpecFactory