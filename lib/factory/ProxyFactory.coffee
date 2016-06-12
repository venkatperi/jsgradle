BaseFactory = require './BaseFactory'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[0])

class ProxyFactory extends BaseFactory
  constructor : ( opts = {}) ->
    @obj = opts.target or throw new Error "Missing option: target"
    super opts

  newInstance : (builder, name) =>
    log.v 'newInstance', name
    @obj
   
module.exports = ProxyFactory