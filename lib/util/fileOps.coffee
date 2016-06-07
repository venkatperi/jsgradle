###
   File file(Object path);
    File file(Object path, PathValidation validation);
    URI uri(Object path);
    FileResolver getFileResolver();
    String relativePath(Object path);
    ConfigurableFileCollection files(Object... paths);
    ConfigurableFileTree fileTree(Object baseDir);
    ConfigurableFileTree fileTree(Map<String, ?> args);
    FileTree zipTree(Object zipPath);
    FileTree tarTree(Object tarPath);
    CopySpec copySpec();
    WorkResult copy(Action<? super CopySpec> action);
    WorkResult sync(Action<? super CopySpec> action);
    File mkdir(Object path);
    boolean delete(Object... paths);
    WorkResult delete(Action<? super DeleteSpec> action);
    ResourceHandler getResources();
###

path = require 'path'
Q = require 'q'
fs = require 'fs'
mkdirp = require 'mkdirp'

mkdirp = Q.denodeify mkdirp
stat = Q.denodeify fs.stat
unlink = Q.denodeify fs.unlink
lstat = Q.denodeify fs.lstat
readFile = Q.denodeify fs.readFile

isDir = ( name ) ->
  stat name
  .then ( stats ) ->
    return stats.isDirectory()
  .fail ( err ) ->
    throw err unless err.code is 'ENOENT'
    false

copyFile = ( src, dest, opts = {} ) ->
  defer = Q.defer()
  _stat = if opts.dereference then stat else lstat
  target =
    name : dest

  isDir dest
  .then ( val ) ->
    dest = path.join dest, path.basename(src) if val
    _stat dest
  .then ( stats ) ->
    target.exists = true
    target.mtime = stats.mtime
    target.atime = stats.atime
    target.isFile = stats.isFile()
    target.isDir = stats.isDirectory()
    target
  .fail ( err ) ->
    throw err unless err.code is 'ENOENT'
    target
  .then ->
    if target.exists and target.isFile and opts.noclobber
      throw new Error "Destination exists. won't clobber: #{dest}"
    return if target.exists or target.isFile
    destDir = path.dirname dest
    mkdirp destDir
  .then -> _stat src
  .then ( stats ) ->
    throw new Error "Not a file: #{src}" unless stats.isFile()
    name : src
    mode : stats.mode
    mtime : stats.mtime
    atime : stats.atime
  .then ( file ) ->

    readStream = fs.createReadStream(file.name)
    readStream.on 'error', defer.reject

    writeStream = fs.createWriteStream(dest, mode : opts.mode)
    writeStream.on 'error', defer.reject

    if opts.transform?
      opts.transform readStream, writeStream, file
    else
      writeStream.on 'open', -> readStream.pipe writeStream

    writeStream.once 'finish', ->
      fs.utimesSync dest, file.atime, file.mtime if opts.modified
      defer.resolve()

    defer.promise

module.exports = {
  mkdirp,
  readFile
  copyFile
  unlink
}
