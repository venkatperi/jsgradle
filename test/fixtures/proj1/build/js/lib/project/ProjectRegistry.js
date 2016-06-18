var ProjectRegistry,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ProjectRegistry = (function() {
  function ProjectRegistry() {
    this._addProjectToParentSubProjects = bind(this._addProjectToParentSubProjects, this);
    this.allProjects = bind(this.allProjects, this);
    this.getProject = bind(this.getProject, this);
    this.removeProject = bind(this.removeProject, this);
    this.addProject = bind(this.addProject, this);
    this._projects = new Map();
    this._subProjects = new Map();
  }

  ProjectRegistry.prototype.addProject = function(proj) {
    this._projects.set(proj.fullPath, proj);
    this._subProjects.set(proj.fullPath, new Set());
    return this._addProjectToParentSubProjects(proj);
  };

  ProjectRegistry.prototype.removeProject = function(path) {
    var p, proj, results;
    proj = this._projects["delete"](path);
    if (proj == null) {
      throw new Error("bad path: " + path);
    }
    this._subprojects["delete"](path);
    results = [];
    while ((p = proj.parent)) {
      results.push(this._subProjects.get(p.fullPath)["delete"](proj));
    }
    return results;
  };

  ProjectRegistry.prototype.getProject = function(name) {
    return this._items.get(name);
  };

  ProjectRegistry.prototype.allProjects = function() {
    return this._items.values();
  };

  ProjectRegistry.prototype._addProjectToParentSubProjects = function(proj) {
    var p, results;
    results = [];
    while ((p = proj.parent)) {
      results.push(subProjects.get(p.fullPath).add(proj));
    }
    return results;
  };

  return ProjectRegistry;

})();

module.exports = ProjectRegistry;
