path = require 'path'
assert = require 'assert'
should = require 'should'
rek = require 'rekuire'
CopySpec = rek 'CopySpec'

describe 'CopySpec', ->

  spec = undefined
  beforeEach ->
    spec = new CopySpec()
    lib = new CopySpec srcDir: 'lib'
    lib.include '**/*.coffee'
    lib.exclude '**/*.js'
    spec.setChild lib
    root = new CopySpec srcDir: '.', dest: 'bc'
    root.include '*.coffee'
    root.exclude '*/*.js'
    into = new CopySpec dest: 'dist'
    spec.setChild into
    spec.setChild root

  it 'flatten glob patterns', ->
    console.log spec.patterns

  it 'all destinations', ->
    console.log spec.allDest


