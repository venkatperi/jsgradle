var Q, changeExt, copyFile, fs, isDir, isDirSync, isFile, isFileSync, isType, isTypeSync, lstat, mkdirp, path, readFile, rmdir, stat, unlink, writeFile, writeFileMkdir, writeFileMkdirSync;

path = require('path');

Q = require('q');

fs = require('fs');

mkdirp = require('mkdirp');

rmdir = require('rmdir');

rmdir = Q.denodeify(rmdir);

stat = Q.denodeify(fs.stat);

unlink = Q.denodeify(fs.unlink);

lstat = Q.denodeify(fs.lstat);

readFile = Q.denodeify(fs.readFile);

writeFile = Q.denodeify(fs.writeFile);

isType = function(type) {
  return function(name) {
    return stat(name).then(function(stats) {
      return stats["is" + type]();
    }).fail(function(err) {
      if (err.code !== 'ENOENT') {
        throw err;
      }
      return false;
    });
  };
};

isDir = isType('Directory');

isFile = isType('File');

isTypeSync = function(type) {
  return function(name) {
    var err, error, stats;
    try {
      stats = fs.statSync(name);
      return stats["is" + type]();
    } catch (error) {
      err = error;
      if (err.code !== 'ENOENT') {
        throw err;
      }
      return false;
    }
  };
};

isDirSync = isTypeSync('Directory');

isFileSync = isTypeSync('File');

copyFile = function(src, dest, opts) {
  var _stat, defer, target;
  if (opts == null) {
    opts = {};
  }
  defer = Q.defer();
  _stat = opts.dereference ? stat : lstat;
  target = {
    name: dest
  };
  return isDir(dest).then(function(val) {
    if (val) {
      dest = path.join(dest, path.basename(src));
    }
    return _stat(dest);
  }).then(function(stats) {
    target.exists = true;
    target.mtime = stats.mtime;
    target.atime = stats.atime;
    target.isFile = stats.isFile();
    target.isDir = stats.isDirectory();
    return target;
  }).fail(function(err) {
    if (err.code !== 'ENOENT') {
      throw err;
    }
    return target;
  }).then(function() {
    var destDir;
    if (target.exists && target.isFile && opts.noclobber) {
      throw new Error("Destination exists. won't clobber: " + dest);
    }
    if (target.exists || target.isFile) {
      return;
    }
    destDir = path.dirname(dest);
    return mkdirp(destDir);
  }).then(function() {
    return _stat(src);
  }).then(function(stats) {
    if (!stats.isFile()) {
      throw new Error("Not a file: " + src);
    }
    return {
      name: src,
      mode: stats.mode,
      mtime: stats.mtime,
      atime: stats.atime
    };
  }).then(function(file) {
    var readStream, writeStream;
    readStream = fs.createReadStream(file.name);
    readStream.on('error', defer.reject);
    writeStream = fs.createWriteStream(dest, {
      mode: opts.mode
    });
    writeStream.on('error', defer.reject);
    if (opts.transform != null) {
      opts.transform(readStream, writeStream, file);
    } else {
      writeStream.on('open', function() {
        return readStream.pipe(writeStream);
      });
    }
    writeStream.once('finish', function() {
      if (opts.modified) {
        fs.utimesSync(dest, file.atime, file.mtime);
      }
      return defer.resolve();
    });
    return defer.promise;
  });
};

changeExt = function(file, ext) {
  var parts;
  parts = path.parse(file);
  parts.ext = ext;
  delete parts.base;
  return path.format(parts);
};

writeFileMkdir = function(file, data) {
  var dir;
  dir = path.dirname(file);
  return mkdirp(dir).then(function() {
    return writeFile(file, data);
  });
};

writeFileMkdirSync = function(file, data) {
  var dir;
  dir = path.dirname(file);
  mkdirp.sync(dir);
  return fs.writeFileSync(file, data);
};

module.exports = {
  mkdirp: mkdirp,
  readFile: readFile,
  copyFile: copyFile,
  unlink: unlink,
  writeFile: writeFile,
  writeFileMkdir: writeFileMkdir,
  writeFileMkdirSync: writeFileMkdirSync,
  changeExt: changeExt,
  isDir: isDir,
  isFile: isFile,
  isDirSync: isDirSync,
  isFileSync: isFileSync,
  readFileSync: fs.readFileSync,
  writeFileSync: fs.writeFileSync,
  rmdir: rmdir
};
