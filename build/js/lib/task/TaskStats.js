var TaskStats, prop, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

rek = require('rekuire');

prop = rek('prop');

TaskStats = (function() {
  prop(TaskStats, 'didWork', {
    get: function() {
      return this.notCached > 0;
    }
  });

  prop(TaskStats, 'hasFiles', {
    get: function() {
      return this.files != null;
    }
  });

  prop(TaskStats, 'notCached', {
    get: function() {
      return this.files - this.cached;
    }
  });

  function TaskStats() {
    this.file = bind(this.file, this);
  }

  TaskStats.prototype.file = function(cached) {
    if (this.files == null) {
      this.files = 0;
    }
    if (this.cached == null) {
      this.cached = 0;
    }
    this.files++;
    if (cached) {
      return this.cached++;
    }
  };

  return TaskStats;

})();

module.exports = TaskStats;
