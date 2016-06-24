Plugin = undefined
try
  rek = require 'rekuire'
  Plugin = rek 'GulpCompilePlugin'
catch
  Plugin = require('kohi').GulpCompilePlugin

class CoffeescriptPlugin extends Plugin

module.exports = CoffeescriptPlugin