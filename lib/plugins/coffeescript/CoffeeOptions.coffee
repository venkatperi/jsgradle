_ = require 'lodash'
rek = require 'rekuire'
conf = rek 'conf'
configurable = rek 'configurable'

module.exports = ( f ) ->
  opt = configurable f
  _.extend opt, conf.get 'plugin:coffeescript:options', {}
