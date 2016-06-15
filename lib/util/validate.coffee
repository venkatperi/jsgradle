_ = require 'lodash'

ensureOptions = ( obj, names... ) =>
  items = {}
  for n in _.flatten names
    throw new Error "Missing option: #{n}" unless obj?[ n ]?
    items[ n ] = obj[ n ]
  items

module.exports = {
  ensureOptions
}
  