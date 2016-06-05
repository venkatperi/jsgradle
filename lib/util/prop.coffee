module.exports = ( obj, name, config ) ->
  Object.defineProperty obj.prototype, name, config
