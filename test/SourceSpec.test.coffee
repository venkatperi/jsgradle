path = require 'path'
assert = require 'assert'
should = require 'should'
SourceSpec = require '../lib/task/SourceSpec'
SourceSet = require '../lib/task/FileSourceSet'
FileResolver = require '../lib/task/FileResolver'
log = require('../lib/util/logger')('SourceSpec.test')

log.level 'verbose'

resolver = new FileResolver projectDir : path.join __dirname, 'fixtures'

describe 'SourceSpec', ->

  it 'default includes all files', ->
    spec = new SourceSpec srcDir : 'proj1'
    spec.doConfigure()
    set = new SourceSet spec: spec
    set.resolve resolver
    .then ( files ) ->
      console.log files

  it 'with excludes', ->
    spec = new SourceSpec srcDir : 'proj1'
    spec.include '**/*.coffee'
    spec.exclude '**/T*.coffee'
    spec.doConfigure()
    spec.resolve resolver
    .then ( files ) ->
      console.log files

  it 'with child specs', ->
    spec = new SourceSpec srcDir : 'proj1'
    spec.include '*.{kohi,coffee}'
    spec.exclude '**/T*.coffee'
    lib = new SourceSpec srcDir : 'lib', parent : spec
    lib.include '**/*.coffee'
    spec.sources.push lib
    spec.doConfigure()
    spec.resolve resolver
    .then ( files ) ->
      console.log files

