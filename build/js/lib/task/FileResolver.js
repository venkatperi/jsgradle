var FileResolver, path,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

FileResolver = (function() {
  function FileResolver(arg) {
    this.projectDir = arg.projectDir;
    this.file = bind(this.file, this);
  }

  FileResolver.prototype.file = function(name) {
    return path.normalize(path.resolve(this.projectDir, name));
  };

  return FileResolver;

})();

module.exports = FileResolver;
