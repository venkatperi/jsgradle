class ProjectRegistry
  constructor : () ->
    @_projects = new Map()
    @_subProjects = new Map()

  addProject : ( proj ) =>
    @_projects.set proj.fullPath, proj
    @_subProjects.set proj.fullPath, new Set()
    @_addProjectToParentSubProjects proj

  removeProject : ( path ) =>
    proj = @_projects.delete path
    throw new Error "bad path: #{path}" unless proj?
    @_subprojects.delete path
    while (p = proj.parent)
      @_subProjects.get(p.fullPath).delete proj

  getProject : ( name ) =>
    @_items.get name

  allProjects : =>
    @_items.values()

  _addProjectToParentSubProjects : ( proj ) =>
    while (p = proj.parent)
      subProjects.get(p.fullPath).add proj

module.exports = ProjectRegistry