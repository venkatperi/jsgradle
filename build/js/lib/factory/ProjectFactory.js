var BaseFactory, Project, ProjectFactory, _, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

BaseFactory = require('./BaseFactory');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

Project = rek('lib/project/Project');

ProjectFactory = (function(superClass) {
  extend(ProjectFactory, superClass);

  function ProjectFactory() {
    this.newInstance = bind(this.newInstance, this);
    return ProjectFactory.__super__.constructor.apply(this, arguments);
  }

  ProjectFactory.prototype.newInstance = function(builder, name, value, args) {
    var opts, proj;
    opts = _.extend({}, args);
    opts.name = value;
    opts.script = this.script;
    proj = new Project(opts);
    this.script.project = proj;
    this.script.listenTo(proj);
    return proj;
  };

  return ProjectFactory;

})(BaseFactory);

module.exports = ProjectFactory;
