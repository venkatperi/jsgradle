path = require 'path'

class FileResolver
  constructor : ( {@projectDir} ) ->
    
  file: (name) =>
    path.normalize path.resolve @projectDir, name 

module.exports = FileResolver