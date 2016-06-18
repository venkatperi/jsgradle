path = require 'path'
rek = require 'rekuire'
Collection = rek 'Collection'

class SourceSetOutput extends Collection

  @_addProperties
    required : [ 'dir' ]
    optional : [ 'parent' ]
    exported : [ 'dir' ]

module.exports = SourceSetOutput