var CopyAction, CopySpec, CopyTask, Q, Task, _, glob, multi, path,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Q = require('q');

_ = require('lodash');

Task = require('../Task');

CopySpec = require('./copy/CopySpec');

CopyAction = require('./CopyAction');

multi = require('heterarchy').multi;

glob = require('../../util/glob');

path = require('path');

CopyTask = (function(superClass) {
  extend(CopyTask, superClass);

  function CopyTask(opts) {
    if (opts == null) {
      opts = {};
    }
    this.resolveSourceFiles = bind(this.resolveSourceFiles, this);
    this.createActions = bind(this.createActions, this);
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    opts.type = 'Copy';
    CopyTask.__super__.constructor.call(this, opts);
  }

  CopyTask.prototype.onAfterEvaluate = function(p) {
    return this.createActions();
  };

  CopyTask.prototype.createActions = function() {
    var dest;
    dest = this.destinations[0];
    return this.resolveSourceFiles().then((function(_this) {
      return function(files) {
        var f, j, len, results;
        results = [];
        for (j = 0, len = files.length; j < len; j++) {
          f = files[j];
          results.push(_this.actions.push(new CopyAction(f, dest, {
            cwd: _this.project.projectDir
          })));
        }
        return results;
      };
    })(this));
  };

  CopyTask.prototype.resolveSourceFiles = function() {
    var baseDir, prev, res;
    res = {
      includes: [],
      excludes: []
    };
    prev = Q(true);
    baseDir = this.project.projectDir;
    this.sources.forEach(function(s) {
      var dir;
      dir = path.join(baseDir, s.src);
      return ['includes', 'excludes'].forEach(function(t) {
        return s[t].forEach(function(pat) {
          return prev = prev.then(function() {
            return glob(pat, {
              cwd: dir
            });
          }).then(function(list) {
            var i;
            return res[t].push((function() {
              var j, len, results;
              results = [];
              for (j = 0, len = list.length; j < len; j++) {
                i = list[j];
                results.push(path.join(dir, i));
              }
              return results;
            })());
          });
        });
      });
    });
    return prev.then(function() {
      return _.difference(_.flatten(res.includes), _.flatten(res.excludes));
    });
  };

  return CopyTask;

})(multi(Task, CopySpec));

module.exports = CopyTask;
