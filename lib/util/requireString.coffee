module.exports = ( src, filename ) ->
  m = new (module.constructor)
  m.paths = module.paths
  m._compile src, filename
  m.exports
