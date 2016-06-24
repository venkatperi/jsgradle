var ClearCacheTask, FileCachePlugin, Plugin, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Plugin = require('./Plugin');

rek = require('rekuire');

ClearCacheTask = rek('ClearCacheTask');

FileCachePlugin = (function(superClass) {
  extend(FileCachePlugin, superClass);

  function FileCachePlugin() {
    this.doApply = bind(this.doApply, this);
    return FileCachePlugin.__super__.constructor.apply(this, arguments);
  }

  FileCachePlugin.prototype.doApply = function() {
    this.applyPlugin('build');
    this.register({
      taskFactory: {
        clearCache: ClearCacheTask
      }
    });
    return this.task('clean').dependsOn('clearCache');
  };

  return FileCachePlugin;

})(Plugin);

module.exports = FileCachePlugin;
