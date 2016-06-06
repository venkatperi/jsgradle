assert = require 'assert'
should = require 'should'
CopyTask = require '../lib/task/builtin/CopyTask'

describe 'CopyTask', ->

  it 'inherits mixin from CopySpec', ->
    c = new CopyTask name: 'test'
    console.log c.from()


