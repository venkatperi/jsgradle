path = require 'path'
rek = require 'rekuire'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class SourceSetOutput

  constructor : ( {@parent, @name} ) ->

  hasProperty : ( name ) =>
    name in [ 'dir' ]

  getProperty : ( name ) => @[ name ]

  setProperty : ( k, v ) => @[ k ] = v

module.exports = SourceSetOutput