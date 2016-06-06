fs = require('fs')
path = require('path')
Q = require 'q'

ncp = ( sources, dest, options, callback ) ->
  cback = callback

  startCopy = ( source ) ->
    started++
    if filter instanceof RegExp
      return cb(true) unless filter.test(source)

    if typeof filter == 'function'
      return cb(true) unless filter(source)

    getStats source

  getStats = ( source ) ->
    stat = if dereference then fs.stat else fs.lstat
    if running >= limit
      return setImmediate -> getStats source

    running++
    stat source, ( err, stats ) ->
      item = {}
      return onError(err) if err

      # We need to get the mode from the stats object and preserve it.
      item.name = source
      item.mode = stats.mode
      item.mtime = stats.mtime
      #modified time
      item.atime = stats.atime
      #access time
      return onDir(item) if stats.isDirectory()
      return onFile(item) if stats.isFile()
      return onLink(source) if stats.isSymbolicLink()

  onFile = ( file ) ->
    console.log file
    target = file.name.replace(currentPath, targetPath)
    target = rename(target) if rename

    isWritable target, ( writable ) ->
      return copyFile(file, target) if writable

      if clobber
        rmFile target, -> copyFile file, target

      return cb() unless modified
      stat = if dereference then fs.stat else fs.lstat
      stat target, ( err, stats ) ->
        #if souce modified time greater to target modified time copy file
        return cb() unless file.mtime.getTime() > stats.mtime.getTime()
        copyFile file, target

  copyFile = ( file, target ) ->
    readStream = fs.createReadStream(file.name)
    writeStream = fs.createWriteStream(target, mode : file.mode)
    readStream.on 'error', onError
    writeStream.on 'error', onError

    if transform
      transform readStream, writeStream, file
    else
      writeStream.on 'open', ->
        readStream.pipe writeStream

    writeStream.once 'finish', ->
      if modified
        #target file modified date sync.
        fs.utimesSync target, file.atime, file.mtime
      cb()

  rmFile = ( file, done ) ->
    fs.unlink file, ( err ) ->
      return onError(err) if err
      done()

  onDir = ( dir ) ->
    target = dir.name.replace(currentPath, targetPath)
    isWritable target, ( writable ) ->
      return mkDir(dir, target) if writable
      copyDir dir.name

  mkDir = ( dir, target ) ->
    fs.mkdir target, dir.mode, ( err ) ->
      return onError(err) if err
      copyDir dir.name

  copyDir = ( dir ) ->
    fs.readdir dir, ( err, items ) ->
      return onError(err) if err
      items.forEach ( item ) ->
        startCopy path.join(dir, item)
      cb()

  onLink = ( link ) ->
    target = link.replace(currentPath, targetPath)
    fs.readlink link, ( err, resolvedPath ) ->
      return onError(err) if err
      checkLink resolvedPath, target

  checkLink = ( resolvedPath, target ) ->
    if dereference
      resolvedPath = path.resolve(basePath, resolvedPath)

    isWritable target, ( writable ) ->
      if writable
        return makeLink(resolvedPath, target)
      fs.readlink target, ( err, targetDest ) ->
        return onError(err) if err
        if dereference
          targetDest = path.resolve(basePath, targetDest)
        return cb() if targetDest == resolvedPath

        rmFile target, ->
          makeLink resolvedPath, target

  makeLink = ( linkPath, target ) ->
    fs.symlink linkPath, target, ( err ) ->
      return onError(err) if err
      cb()

  isWritable = ( path, done ) ->
    fs.lstat path, ( err ) ->
      if err
        return done(true) if err.code == 'ENOENT'
        done(false)
      done false

  onError = ( err ) ->
    return cback(err) if options.stopOnError

    errs = []
    if !errs and options.errs
      errs = fs.createWriteStream(options.errs)

    if typeof errs.write == 'undefined'
      errs.push err
    else
      errs.write err.stack + '\n\n'
    cb()

  cb = ( skipped ) ->
    running-- if !skipped
    finished++
    if started == finished and running == 0
      if cback != undefined
        return if errs then cback(errs) else cback(null, finished)

  if !callback
    cback = options
    options = {}

  basePath = options.cwd or process.cwd()
  targetPath = path.resolve(basePath, dest)
  filter = options.filter
  rename = options.rename
  transform = options.transform
  clobber = options.clobber != false
  modified = options.modified
  dereference = options.dereference
  errs = null
  started = 0
  finished = 0
  running = 0
  limit = options.limit or ncp.limit or 16
  limit = if limit < 1 then 1 else if limit > 512 then 512 else limit

  sources = [ sources ] unless Array.isArray sources
  console.log targetPath
  for s in sources
    currentPath = path.resolve(basePath, s)
    startCopy currentPath

module.exports = ncp
