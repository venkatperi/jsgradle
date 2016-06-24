Plugin = undefined
try
  rek = require 'rekuire'
  Plugin = rek 'GulpCompilePlugin'
catch
  Plugin = require('kohi').GulpCompilePlugin

class BabelPlugin extends Plugin

module.exports = BabelPlugin