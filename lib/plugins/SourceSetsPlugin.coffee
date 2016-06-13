Plugin = require './Plugin'
rek = require 'rekuire'
out = rek 'out'
ProxyFactory = rek 'ProxyFactory'
SourceSetContainer = rek 'SourceSetContainer'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class SourceSetsPlugin extends Plugin
  constructor : ->

  apply : ( project ) =>
    log.v 'apply'
    return if @configured
    super project
    @sourceSets = new SourceSetContainer parent : project, name: 'root'
    project.extensions.add 'sourceSets', @sourceSets
    project.script.registerFactory 'sourceSets',
      new ProxyFactory target : @sourceSets, script : project.script

module.exports = SourceSetsPlugin