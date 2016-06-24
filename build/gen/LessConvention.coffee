Convention = undefined
try
  rek = require 'rekuire'
  Convention = rek 'SourceMapConvention'
catch
  Convention = require('kohi').SourceMapConvention

class LessConvention extends Convention

module.exports = LessConvention