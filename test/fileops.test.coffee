Q = require 'q'
assert = require 'assert'
should = require 'should'
{copyFile} = require '../lib/util/fileOps'
path = require 'path'
fs = require 'fs'
execFile = require('child_process').execFile

exec = ( file, args ) ->
  defer = Q.defer()
  execFile file, args, ( err, stdout, stderr ) ->
    return defer.reject err if err?
    defer.resolve stdout, stderr
  defer.promise

fixture = ( name ) ->
  path.join __dirname, 'fixtures', name

isFile = ( name ) ->
  try
    return fs.statSync(name).isFile()
  catch
    return false

diff = ( a, b ) ->
  exec '/usr/bin/diff', [ a, b ]

describe 'fileOps', ->

  describe 'copyFile', ->

    beforeEach ->
      try
        fs.unlinkSync '/tmp/abc'
      catch

    it 'file to file', ( done ) ->
      src = fixture 'proj1/build.kohi'
      dest = '/tmp/abc/build.kohi'
      copyFile src, dest
      .then ->
        assert isFile dest
        diff src, dest
      .then -> done()
      .fail done

    it 'file to dir', ( done ) ->
      src = fixture 'proj1/build.kohi'
      dest = '/tmp'
      destFile = path.join dest, 'build.kohi'
      copyFile src, dest
      .then ->
        assert isFile destFile
        diff src, destFile
      .then -> done()
      .fail done

    it 'file to file, no clobber', ( done ) ->
      src = fixture 'proj1/build.kohi'
      dest = '/tmp/build.kohi'
      copyFile src, dest, noclobber : true
      .then ->
        assert isFile dest
        diff src, dest
      .then -> done 'hm...'
      .fail ( err ) ->
        done()


