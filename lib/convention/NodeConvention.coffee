rek = require 'rekuire'
Convention = rek 'Convention'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class NodeConvention extends Convention

  createConfigurations : =>
    for c in [ 'runtime', 'dev' ]
      @createConfiguration c unless @configurationExists c

module.exports = NodeConvention