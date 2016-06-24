Convention = undefined
try
  rek = require 'rekuire'
  Convention = rek 'SourceMapConvention'
catch
  Convention = require('kohi').SourceMapConvention

class SassConvention extends Convention

module.exports = SassConvention