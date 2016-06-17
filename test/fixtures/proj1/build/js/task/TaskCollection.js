var Collection, TaskCollection, _,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

Collection = require('../util/Collection');

TaskCollection = (function(superClass) {
  extend(TaskCollection, superClass);

  function TaskCollection() {}

  return TaskCollection;

})(Collection);

module.exports = TaskCollection;
