var BuildsPlugin, Plugin,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

BuildsPlugin = (function(superClass) {
  extend(BuildsPlugin, superClass);

  function BuildsPlugin() {
    this.doApply = bind(this.doApply, this);
    return BuildsPlugin.__super__.constructor.apply(this, arguments);
  }

  BuildsPlugin.prototype.doApply = function() {
    this.createTask('build');
    this.createTask('clean');
    this.project.defaultTasks('build');
    this.task('clean').enabled = false;
    return this.task('build').dependsOn('clean');
  };

  return BuildsPlugin;

})(Plugin);

module.exports = BuildsPlugin;
