path = require 'path'
assert = require 'assert'
should = require 'should'
Script = require '../lib/Script'

describe 'Script', ->

  it 'initialize', ->
    s = new Script scriptFile : path.join __dirname, 'fixtures', 'script1.coffee'
    s.initialize()
    s.project.name.should.equal 'script1'
    s.project.description.should.equal 'project script1'
    s.project.version.should.equal '0.1.0'

  it 'configure', ->
    s = new Script scriptFile : path.join __dirname, 'fixtures', 'script1.coffee'
    s.configure()
    s.project.name.should.equal 'script1'
    s.project.description.should.equal 'test project'
    s.project.version.should.equal '0.2.0'

  it 'execute', ->
    s = new Script scriptFile : path.join __dirname, 'fixtures', 'script1.coffee'
    s.execute()
    s.project.name.should.equal 'script1'
    s.project.description.should.equal 'test project'
    s.project.version.should.equal '0.2.0'

