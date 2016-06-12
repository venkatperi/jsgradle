BaseFactory = require './BaseFactory'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])
CopySpec = rek 'CopySpec'

class CopySpecFactory extends BaseFactory

  newInstance : ( builder, name, value, args ) =>
    log.v 'newInstance'
    opts = {}
    switch name
      when 'from' then opts.srcDir = value
      when 'into' then opts.dest = value
      when 'filter' then opts.filter = value
    new CopySpec opts

module.exports = CopySpecFactory