var PackageOptions, _, log, properties, readFileSync, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ = require('lodash');

rek = require('rekuire');

readFileSync = rek('fileOps').readFileSync;

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

properties = ['name', 'description', 'keywords', 'preferGlobal', 'homepage', 'bugs', 'license', 'author', 'contributors', 'main', 'bin', 'repository', 'scripts', 'man', 'dist', 'gitHead', 'maintainers'];

PackageOptions = (function() {
  function PackageOptions() {
    this.load = bind(this.load, this);
    this.setProperty = bind(this.setProperty, this);
    this.getProperty = bind(this.getProperty, this);
    this.hasProperty = bind(this.hasProperty, this);
  }

  PackageOptions.prototype.hasProperty = function(name) {
    log.i('hasProperty', name);
    return indexOf.call(properties, name) >= 0;
  };

  PackageOptions.prototype.getProperty = function(name) {
    log.i('getProperty', name);
    return this.pkg[name];
  };

  PackageOptions.prototype.setProperty = function(name, value) {
    log.i('setProperty', name, value);
    return this.pkg[name] = value;
  };

  PackageOptions.prototype.load = function(file) {
    var pkg;
    this.filename = file;
    pkg = JSON.parse(readFileSync(file, 'utf8'));
    this.pkg = {};
    this.original = {};
    _.extend(this.pkg, pkg);
    return _.extend(this.original, pkg);
  };

  return PackageOptions;

})();

module.exports = PackageOptions;
