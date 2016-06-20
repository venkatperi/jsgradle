path = require 'path'
assert = require 'assert'
should = require 'should'
rek = require 'rekuire'
FileCache = rek 'FileCache'
loremHipsum = require 'lorem-hipsum'

describe 'FileCache', ->

  cache = undefined
  beforeEach ->
    cache = new FileCache()

  it 'add a value', ( done ) ->
    contents = loremHipsum
    cache.set 'test', contents
    .then ->
      cache.get 'test'
    .then ( v ) ->
      assert.equal v.contents, contents
      done()
    .fail done

  it 'get key not in cache', ( done ) ->
    cache.get 'tsdfasdfiasdfest'
    .then (v) ->
      assert !v
      done()
    .fail done



