var Task, UpdatePkgAction, UpdatePkgTask, deepEqual, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Task = rek('lib/task/Task');

UpdatePkgAction = require('./UpdatePkgAction');

prop = rek('prop');

deepEqual = require('deep-equal');

UpdatePkgTask = (function(superClass) {
  extend(UpdatePkgTask, superClass);

  function UpdatePkgTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    return UpdatePkgTask.__super__.constructor.apply(this, arguments);
  }

  prop(UpdatePkgTask, 'pkg', {
    get: function() {
      return this.project.extensions.get('pkg');
    }
  });

  UpdatePkgTask.prototype.onAfterEvaluate = function() {
    var originalPkg, pkg;
    pkg = this.project.extensions.get('pkg');
    originalPkg = this.project.extensions.get('__pkg');
    if (!deepEqual(pkg, originalPkg.pkg)) {
      return this.doLast(new UpdatePkgAction({
        task: this,
        filename: originalPkg.filename,
        pkg: pkg
      }));
    }
  };

  return UpdatePkgTask;

})(Task);

module.exports = UpdatePkgTask;
