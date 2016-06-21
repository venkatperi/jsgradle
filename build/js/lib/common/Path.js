var Path, SEP, isAbsolute, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

rek = require('rekuire');

prop = rek('prop');

SEP = ':';

isAbsolute = function(path) {
  return (path != null ? path.indexOf(SEP) : void 0) === 0;
};


/*
Public: Represents path to a project/task
 */

Path = (function() {
  Path.SEP = SEP;

  prop(Path, 'depth', {
    get: function() {
      return this._segments.length;
    }
  });

  prop(Path, 'path', {
    get: function() {
      return this.fullPath;
    }

    /*
    Public: Create a new path object
     
    * `path` (optional) {String} Initial path of this object
     */
  });

  function Path(path, absolute) {
    if (absolute == null) {
      absolute = true;
    }
    this.relativePath = bind(this.relativePath, this);
    this.absolutePath = bind(this.absolutePath, this);
    this.parent = bind(this.parent, this);
    this.toString = bind(this.toString, this);
    this._segments = [];
    this.absolute = absolute;
    if (typeof path === 'string') {
      this.absolute = isAbsolute(path);
      if (this.absolute) {
        path = path.slice(1);
      }
      this._segments = path.split(SEP);
    } else if (Array.isArray(path)) {
      this._segments = path;
      this.absolute = absolute;
    }
    this.fullPath = this._segments.join(SEP);
    if (this.absolute) {
      this.fullPath = SEP + this.fullPath;
    }
    this.prefix = this.fullPath[-1] === SEP ? this.fullPath : this.fullPath + SEP;
  }

  Path.prototype.toString = function() {
    return this.fullPath;
  };


  /*
  Public: Returns the parent of this path, or null if this path 
  has no parent.
  
  Returns {Path} parent of this path or null
   */

  Path.prototype.parent = function() {
    if (!this._segments.length) {
      return;
    }
    if (this.depth === 1) {
      if (this.absolute) {
        return new Path();
      } else {
        return void 0;
      }
    }
    return new Path(this._segments.slice(0, +(this._segments.length - 2) + 1 || 9e9), this.absolute);
  };

  Path.prototype.absolutePath = function(path) {
    if (!isAbsolute(path)) {
      path = this.prefix + path;
    }
    return path;
  };

  Path.prototype.relativePath = function(path) {
    if (path.length > this.prefix.length && path.indexOf(this.prefix) === 0) {
      return path.slice(this.prefix.length);
    }
    return path;
  };

  return Path;

})();

module.exports = Path;
