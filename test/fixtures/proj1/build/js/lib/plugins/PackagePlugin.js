var PackagePlugin, Plugin,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

PackagePlugin = (function(superClass) {
  extend(PackagePlugin, superClass);

  function PackagePlugin() {
    this.apply = bind(this.apply, this);
    this.name = 'package';
    this["package"] = {
      description: void 0,
      keywords: [],
      preferGlobal: false,
      homepage: void 0,
      bugs: {},
      license: void 0,
      author: {},
      contributors: [],
      main: void 0,
      bin: void 0,
      repository: {},
      scripts: {},
      man: [],
      dist: {},
      gitHead: void 0,
      maintainers: {}
    };
  }

  PackagePlugin.prototype.apply = function(project) {
    PackagePlugin.__super__.apply.call(this, project);
    project.extensions.add('pkg', this["package"]);
    return project.task('pkg', null, (function(_this) {
      return function(t, p) {
        t.doFirst(function(p) {
          console.log("pkg: " + _this["package"].description);
          return p.resolve();
        });
        return p.done();
      };
    })(this));
  };

  return PackagePlugin;

})(Plugin);

module.exports = PackagePlugin;
