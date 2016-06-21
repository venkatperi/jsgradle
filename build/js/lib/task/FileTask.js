var FileSourceSet, FileTask, Task, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

Task = require('./Task');

FileSourceSet = require('./FileSourceSet');

prop = rek('prop');

FileTask = (function(superClass) {
  extend(FileTask, superClass);

  function FileTask() {
    this.onAfterEvaluate = bind(this.onAfterEvaluate, this);
    this.summary = bind(this.summary, this);
    return FileTask.__super__.constructor.apply(this, arguments);
  }

  FileTask._addProperties({
    required: ['spec', 'actionType'],
    optional: ['output', 'options']
  });

  prop(FileTask, 'files', {
    get: function() {
      return this._cache.get('files', function() {
        return new FileSourceSet({
          spec: this.spec
        });
      });
    }
  });

  FileTask.prototype.summary = function() {
    if (this.didWork) {
      return this.didWork + " file(s) OK";
    } else {
      return "UP-TO-DATE";
    }
  };

  FileTask.prototype.onAfterEvaluate = function() {
    var dest, outDir, ref, srcDir;
    srcDir = this.project.fileResolver.file(this.spec.srcDir);
    outDir = ((ref = this.output) != null ? ref.dir : void 0) || this.spec.dest;
    if (outDir != null) {
      dest = this.project.fileResolver.file(outDir);
    }
    return this._configured.resolve(this.files.resolve(this.project.fileResolver).then((function(_this) {
      return function(files) {
        var f, i, len, results;
        results = [];
        for (i = 0, len = files.length; i < len; i++) {
          f = files[i];
          results.push(_this.doLast(new _this.actionType({
            task: _this,
            src: f,
            dest: dest,
            opts: _this.options,
            srcDir: srcDir,
            spec: _this.spec
          })));
        }
        return results;
      };
    })(this)));
  };

  return FileTask;

})(Task);

module.exports = FileTask;
