assert = require 'assert'
should = require 'should'
Path = require '../lib/common/Path'

describe 'Path', ->

  it 'default is root', ->
    p = new Path()
    assert p.fullPath is Path.SEP
    assert p.absolute
    assert p.depth is 0

  it 'absolute path', ->
    p = new Path(':abc')
    assert p.fullPath is ':abc'
    assert p.absolute
    assert p.depth is 1

  it 'relative path', ->
    p = new Path('abc')
    assert p.fullPath is 'abc'
    assert !p.absolute
    assert p.depth is 1

  it 'parent of absolute path', ->
    p = new Path(':abc:def').parent()
    assert p.fullPath is ':abc'
    assert p.absolute
    assert p.depth is 1

  it 'parent of relative path', ->
    p = new Path('abc:def').parent()
    assert p.fullPath is 'abc'
    assert !p.absolute
    assert p.depth is 1

  it 'absolute path from relative', ->
    p = new Path('abc:def').absolutePath 'xyz'
    assert p is 'abc:def:xyz'

  it 'absolute path from absolute', ->
    p = new Path(':abc:def').absolutePath ':xyz'
    assert p is ':xyz'

  it 'relative path ', ->
    p = new Path(':abc').relativePath ':abc:def'
    assert p is 'def'

  it 'relative path ', ->
    p = new Path(':abc').relativePath ':abc'
    assert p is ':abc'

