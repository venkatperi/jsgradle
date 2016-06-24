var rek;

rek = require('rekuire');

module.exports = {
  GulpCompilePlugin: rek('GulpCompilePlugin'),
  cli: rek('cli'),
  SourceMapConvention: rek('SourceMapConvention')
};
