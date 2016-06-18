rek = require 'rekuire'
BaseObject = rek 'BaseObject'
DependencySet = rek 'DependencySet'

class Configuration extends BaseObject

  @_addProperties
    required : [ 'name' ]

  init : ( opts ) =>
    super opts
    @dependencies = new DependencySet parent: @, name: @name

module.exports = Configuration