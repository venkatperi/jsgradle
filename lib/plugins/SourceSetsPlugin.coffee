Plugin = require './Plugin'
rek = require 'rekuire'
out = rek 'out'
ProxyFactory = rek 'ProxyFactory'
SourceSetContainer = rek 'SourceSetContainer'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class SourceSetsPlugin extends Plugin

  doApply : =>
    @sourceSets = new SourceSetContainer parent : @project, name : 'root'
    
    @register
      extensions :
        sourceSets : @sourceSets

module.exports = SourceSetsPlugin