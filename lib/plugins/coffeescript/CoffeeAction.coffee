rek = require 'rekuire'
FileAction = rek 'FileAction'
coffeeScript = require 'coffee-script'

class CoffeeAction extends FileAction
  constructor : ( opts = {} ) ->
    opts.transform = coffeeScript.compile
    opts.ext = '.js'
    super opts

module.exports = CoffeeAction
    


