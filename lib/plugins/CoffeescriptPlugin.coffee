rek = require 'rekuire'
GulpCompilePlugin = require './GulpCompilePlugin'
GulpTask = rek 'GulpTask'

class CoffeescriptPlugin extends GulpCompilePlugin

  init : ( opts )=>
    @gulpType = 'gulp-coffee'
    super opts

module.exports = CoffeescriptPlugin