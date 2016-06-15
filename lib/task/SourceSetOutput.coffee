path = require 'path'
rek = require 'rekuire'
BaseObject = rek 'BaseObject'

class SourceSetOutput extends BaseObject
  
  @_addProperties
    required : [ 'dir' ]
    optional : [ 'parent' ]
    exported : [ 'dir' ]

module.exports = SourceSetOutput