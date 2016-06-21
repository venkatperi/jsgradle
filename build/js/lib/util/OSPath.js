var OSPath, path, prop,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

prop = require('./prop');

OSPath = (function() {
  prop(OSPath, 'isAbsolute', {
    get: function() {
      return path.isAbsolute(this.path);
    }
  });

  prop(OSPath, 'dir', {
    get: function() {
      return this.parts.dir;
    }
  });

  prop(OSPath, 'ext', {
    get: function() {
      return this.parts.ext;
    }
  });

  prop(OSPath, 'fileName', {
    get: function() {
      return this.parts.name;
    }
  });

  prop(OSPath, 'root', {
    get: function() {
      return this.parts.root;
    }
  });

  function OSPath(path1) {
    this.path = path1;
    this.toString = bind(this.toString, this);
    this.resolve = bind(this.resolve, this);
    this.relative = bind(this.relative, this);
    this.join = bind(this.join, this);
    this.normalize = bind(this.normalize, this);
    if (this.path == null) {
      this.path = process.cwd();
    }
    this.parts = path.parse(this.path);
  }

  OSPath.prototype.normalize = function() {
    return new OSPath(path.normalize(this.path));
  };

  OSPath.prototype.join = function(other) {
    if (typeof other === 'string') {
      return new OSPath(path.join(this.path, other));
    }
    if (other instanceof OSPath) {
      return new OSPath(path.join(this.path, other.path));
    }
    throw new Error("Cannot join " + other);
  };

  OSPath.prototype.relative = function(to) {
    return new OSPath(path.relative(this.path, to));
  };

  OSPath.prototype.resolve = function(to) {
    return new OSPath(path.resolve(this.path, to));
  };

  OSPath.prototype.toString = function() {
    return this.path;
  };

  return OSPath;

})();

module.exports = OSPath;
