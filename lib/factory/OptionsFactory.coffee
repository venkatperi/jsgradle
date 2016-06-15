BaseFactory = require './BaseFactory'
rek = require 'rekuire'
configurable = rek 'configurable'

class OptionsFactory extends BaseFactory

  newInstance : ( builder, name, value, args ) =>
    configurable {}, @script.project.callScriptMethod


module.exports = OptionsFactory