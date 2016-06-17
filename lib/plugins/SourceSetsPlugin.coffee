Plugin = require './Plugin'
rek = require 'rekuire'
out = rek 'out'
ProxyFactory = rek 'ProxyFactory'
SourceSetContainer = rek 'SourceSetContainer'

class SourceSetsPlugin extends Plugin

  doApply : =>
    @sourceSets = new SourceSetContainer parent : @project, name : 'root'
    
    @register
      extensions :
        sourceSets : @sourceSets

module.exports = SourceSetsPlugin