Plugin = undefined
try
  rek = require 'rekuire'
  Plugin = rek 'GulpCompilePlugin'
catch
  Plugin = require('kohi').GulpCompilePlugin

class SassPlugin extends Plugin

module.exports = SassPlugin