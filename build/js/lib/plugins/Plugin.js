var BaseObject, Plugin, TaskFactory, _, rek, toObj,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

_ = require('lodash');

rek = require('rekuire');

TaskFactory = rek('TaskFactory');

BaseObject = rek('BaseObject');

toObj = function(x, opts) {
  if (_.isFunction(x)) {
    return new x(opts);
  } else {
    return x;
  }
};

Plugin = (function(superClass) {
  extend(Plugin, superClass);

  function Plugin() {
    this.register = bind(this.register, this);
    this.doApply = bind(this.doApply, this);
    this.extension = bind(this.extension, this);
    this.task = bind(this.task, this);
    this.createTask = bind(this.createTask, this);
    this.getSourceSet = bind(this.getSourceSet, this);
    this.applyPlugin = bind(this.applyPlugin, this);
    this.apply = bind(this.apply, this);
    return Plugin.__super__.constructor.apply(this, arguments);
  }

  Plugin._addProperties({
    required: ['name'],
    optional: ['description']
  });

  Plugin.prototype.apply = function(project) {
    if (this.configured) {
      return;
    }
    this.configured = true;
    this.project = project;
    return this.doApply();
  };

  Plugin.prototype.applyPlugin = function(name) {
    return this.project.apply({
      plugin: name
    });
  };

  Plugin.prototype.getSourceSet = function(name) {
    return this.project.sourceSets.get(name);
  };

  Plugin.prototype.createTask = function() {
    var args, ref;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return (ref = this.project).task.apply(ref, args);
  };

  Plugin.prototype.task = function(name) {
    return this.project.tasks.get(name).task;
  };

  Plugin.prototype.extension = function(name) {
    return this.project.extensions.get(name);
  };

  Plugin.prototype.doApply = function() {};

  Plugin.prototype.register = function(opts) {
    var k, ref, ref1, ref2, ref3, results, v;
    if (opts == null) {
      opts = {};
    }
    ref = opts.extensions;
    for (k in ref) {
      if (!hasProp.call(ref, k)) continue;
      v = ref[k];
      this.project.extensions.add(k, toObj(v));
    }
    ref1 = opts.conventions;
    for (k in ref1) {
      if (!hasProp.call(ref1, k)) continue;
      v = ref1[k];
      this.project.conventions.add(k, toObj(v, {
        name: k
      }));
    }
    ref2 = opts.configurations;
    for (k in ref2) {
      if (!hasProp.call(ref2, k)) continue;
      v = ref2[k];
      this.project.configurations.add(k, toObj(v, {
        name: k
      }));
    }
    ref3 = opts.taskFactory;
    results = [];
    for (k in ref3) {
      if (!hasProp.call(ref3, k)) continue;
      v = ref3[k];
      results.push(TaskFactory.register(k, !v.name ? v : function(x) {
        return new v(x);
      }));
    }
    return results;
  };

  return Plugin;

})(BaseObject);

module.exports = Plugin;
