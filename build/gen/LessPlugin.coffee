Plugin = undefined
try
  rek = require 'rekuire'
  Plugin = rek 'GulpCompilePlugin'
catch
  Plugin = require('kohi').GulpCompilePlugin

class LessPlugin extends Plugin

module.exports = LessPlugin