rek = require 'rekuire'
Plugin = require './Plugin'
NodeConvention = rek 'NodeConvention'
log = rek('logger')(require('path').basename(__filename).split('.')[0])

class NodePlugin extends Plugin
  doApply : =>
    @register
      conventions :
        node : NodeConvention
       
module.exports = NodePlugin