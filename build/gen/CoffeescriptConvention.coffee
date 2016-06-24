Convention = undefined
try
  rek = require 'rekuire'
  Convention = rek 'SourceMapConvention'
catch
  Convention = require('kohi').SourceMapConvention

class CoffeescriptConvention extends Convention

module.exports = CoffeescriptConvention