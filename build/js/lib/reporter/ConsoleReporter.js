var ConsoleReporter, Reporter, out, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

out = rek('out');

Reporter = require('./Reporter');

ConsoleReporter = (function(superClass) {
  extend(ConsoleReporter, superClass);

  function ConsoleReporter() {
    this.onTaskExecuteEnd = bind(this.onTaskExecuteEnd, this);
    this.onTaskExecuteStart = bind(this.onTaskExecuteStart, this);
    this.onProjectAfterEvaluateEnd = bind(this.onProjectAfterEvaluateEnd, this);
    this.onScriptConfigureEnd = bind(this.onScriptConfigureEnd, this);
    this.onScriptConfigureStart = bind(this.onScriptConfigureStart, this);
    this.onError = bind(this.onError, this);
    return ConsoleReporter.__super__.constructor.apply(this, arguments);
  }

  ConsoleReporter.prototype.onError = function(err) {
    return console.log(err);
  };

  ConsoleReporter.prototype.onScriptConfigureStart = function(script) {
    return out.eolThen('Configuring... ');
  };

  ConsoleReporter.prototype.onScriptConfigureEnd = function(script, time) {
    if (!script.failed) {
      return out.ifNewline("> Configuring...").grey(" " + time).eol();
    }
  };

  ConsoleReporter.prototype.onProjectAfterEvaluateEnd = function(project, names) {
    if (project.failed) {
      out.eolThen().white('The following tasks failed in `afterEvaluate`');
      return project.failedTasks.forEach(function(t) {
        return out.eolThen("" + t.displayName).red(" " + t.task.messages + " ").eol();
      });
    }
  };

  ConsoleReporter.prototype.onTaskExecuteStart = function(task) {
    return out.eolThen(task.displayName);
  };

  ConsoleReporter.prototype.onTaskExecuteEnd = function(task, time) {
    if (!task.failed) {
      return out.ifNewline("> " + task.displayName).green(" " + (task.summary()) + " ").grey(time).eol();
    } else {
      return out.ifNewline("> " + task.displayName).red(" " + (task.summary()) + " ").eol();
    }
  };

  return ConsoleReporter;

})(Reporter);

module.exports = ConsoleReporter;
