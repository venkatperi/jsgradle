SourceSpec = require './SourceSpec'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class TargetSpec

  into : ( dir ) =>
    @dest = dir

module.exports = TargetSpec