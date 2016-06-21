var File, objectAssign, objectOmit;

objectOmit = require('object.omit');

objectAssign = require('object-assign');

File = require('vinyl');

module.exports = function(restored) {
  var extraTaskProperties, restoredFile;
  if (restored.contents) {
    if (restored && restored.contents && Array.isArray(restored.contents.data)) {
      restored.contents = new Buffer(restored.contents.data);
    } else if (Array.isArray(restored.contents)) {
      restored.contents = new Buffer(restored.contents);
    } else if (typeof restored.contents === 'string') {
      restored.contents = new Buffer(restored.contents, 'base64');
    }
  }
  restoredFile = new File(restored);
  extraTaskProperties = objectOmit(restored, Object.keys(restoredFile));
  restoredFile.fromCache = true;
  return objectAssign(restoredFile, extraTaskProperties);
};
