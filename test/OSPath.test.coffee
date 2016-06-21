
path = require 'path'
assert = require 'assert'
should = require 'should'
OSPath = require '../lib/util/OSPath'

describe 'OSPath', ->

  it 'defaults to cwd()', ->
    p = new OSPath()
    p.toString().should.equal process.cwd()
    assert p.isAbsolute

  it 'join', ->
    p = new OSPath()
    p.join('test').toString().should.equal path.join process.cwd(), 'test'

  it 'resolve', ->
    p = new OSPath()
    console.log p.resolve 'test'

  it 'relative', ->
    p = new OSPath()
    console.log p.relative 'test'
