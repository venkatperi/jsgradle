assert = require 'assert'
should = require 'should'
Project = require '../lib/Project'

proj = undefined

describe 'Project', ->

  it 'needs a name', ->
    assert.throws -> new Project()

  it 'has path', ->
    proj = new Project name : 'test'
    proj.name.should.equal 'test'
    proj.depth.should.equal 0

  describe 'tasks', ->
    beforeEach ->
      proj = new Project name : 'test'

    it 'needs a name', ->
      assert.throws -> proj.task()

    it 'create task', ->
      task = proj.task 'abc'
      task.name.should.equal 'abc'
      task.type.should.equal 'default'

    it 'task exists', ->
      proj.task 'abc'
      assert.throws -> proj.task 'abc'

    it 'configure task', ( done ) ->
      proj.task 'abc', ( task ) ->
        task.name.should.equal 'abc'
        task.type.should.equal 'default'
        done()
        





    
    
    
