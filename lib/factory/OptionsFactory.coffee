BaseFactory = require './BaseFactory'
rek = require 'rekuire'
configurable = rek 'configurable'

class OptionsFactory extends BaseFactory

  newInstance : ( builder, name, value, args ) =>
    obj = configurable {}, @script.project.callScriptMethod
    obj.__factory = name
    obj


module.exports = OptionsFactory