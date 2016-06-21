var PackageOptions, PackagePlugin, Plugin, TaskFactory, UpdatePkgTask, _, conf, configurable, fs, load, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

rek = require('rekuire');

PackageOptions = rek('PackageOptions');

UpdatePkgTask = rek('UpdatePkgTask');

TaskFactory = rek('TaskFactory');

configurable = rek('configurable');

fs = require('fs');

_ = require('lodash');

conf = rek('conf');

load = (function(_this) {
  return function(file, obj) {
    var pkg;
    pkg = JSON.parse(fs.readFileSync(file, 'utf8'));
    _.extend(obj, pkg);
    return pkg;
  };
})(this);

PackagePlugin = (function(superClass) {
  extend(PackagePlugin, superClass);

  function PackagePlugin() {
    this.doApply = bind(this.doApply, this);
    return PackagePlugin.__super__.constructor.apply(this, arguments);
  }

  PackagePlugin.prototype.doApply = function() {
    var file, pkg;
    this["package"] = configurable(this.project.callScriptMethod);
    file = project.fileResolver.file('package.json');
    pkg = load(file, this["package"]);
    this.register({
      extensions: {
        pkg: this["package"],
        __pkg: {
          filename: file,
          pkg: pkg
        }
      },
      taskFactory: {
        UpdatePkg: UpdatePkgTask
      }
    });
    this.createTask('updatePkg', {
      type: 'UpdatePkg'
    });
    return project.defaultTasks('updatePkg');
  };

  return PackagePlugin;

})(Plugin);

module.exports = PackagePlugin;
