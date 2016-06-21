var BaseFactory, TaskBuilderFactory, _, log, rek, util,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./BaseFactory');

util = require('util');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

_ = require('lodash');

TaskBuilderFactory = (function(superClass) {
  extend(TaskBuilderFactory, superClass);

  function TaskBuilderFactory() {
    this.newInstance = bind(this.newInstance, this);
    return TaskBuilderFactory.__super__.constructor.apply(this, arguments);
  }

  TaskBuilderFactory.prototype.newInstance = function(builder, name, value, attr) {
    var opts;
    log.v('newInstance', value, attr);
    opts = _.extend({}, attr);
    opts.name = value;
    opts.project = this.script.project;
    return this.script.project.tasks.create(opts);
  };

  return TaskBuilderFactory;

})(BaseFactory);

module.exports = TaskBuilderFactory;
