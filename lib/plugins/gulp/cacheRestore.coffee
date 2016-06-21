objectOmit = require 'object.omit'
objectAssign = require 'object-assign'
File = require 'vinyl'

module.exports = ( restored ) ->
  if restored.contents
    # Handle node 0.11 buffer to JSON as object with { type: 'buffer', data: [...] }
    if restored and restored.contents and Array.isArray(restored.contents.data)
      restored.contents = new Buffer(restored.contents.data)
    else if Array.isArray(restored.contents)
      restored.contents = new Buffer(restored.contents)
    else if typeof restored.contents == 'string'
      restored.contents = new Buffer(restored.contents, 'base64')
  restoredFile = new File(restored)
  extraTaskProperties = objectOmit(restored, Object.keys(restoredFile))
  restoredFile.fromCache = true
  # Restore any properties that the original task put on the file;
  # but omit the normal properties of the file
  objectAssign restoredFile, extraTaskProperties
