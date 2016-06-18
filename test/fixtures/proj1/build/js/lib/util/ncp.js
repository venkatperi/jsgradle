var Q, fs, ncp, path;

fs = require('fs');

path = require('path');

Q = require('q');

ncp = function(sources, dest, options, callback) {
  var basePath, cb, cback, checkLink, clobber, copyDir, copyFile, currentPath, dereference, errs, filter, finished, getStats, i, isWritable, len, limit, makeLink, mkDir, modified, onDir, onError, onFile, onLink, rename, results, rmFile, running, s, startCopy, started, targetPath, transform;
  cback = callback;
  startCopy = function(source) {
    started++;
    if (filter instanceof RegExp) {
      if (!filter.test(source)) {
        return cb(true);
      }
    }
    if (typeof filter === 'function') {
      if (!filter(source)) {
        return cb(true);
      }
    }
    return getStats(source);
  };
  getStats = function(source) {
    var stat;
    stat = dereference ? fs.stat : fs.lstat;
    if (running >= limit) {
      return setImmediate(function() {
        return getStats(source);
      });
    }
    running++;
    return stat(source, function(err, stats) {
      var item;
      item = {};
      if (err) {
        return onError(err);
      }
      item.name = source;
      item.mode = stats.mode;
      item.mtime = stats.mtime;
      item.atime = stats.atime;
      if (stats.isDirectory()) {
        return onDir(item);
      }
      if (stats.isFile()) {
        return onFile(item);
      }
      if (stats.isSymbolicLink()) {
        return onLink(source);
      }
    });
  };
  onFile = function(file) {
    var target;
    console.log(file);
    target = file.name.replace(currentPath, targetPath);
    if (rename) {
      target = rename(target);
    }
    return isWritable(target, function(writable) {
      var stat;
      if (writable) {
        return copyFile(file, target);
      }
      if (clobber) {
        rmFile(target, function() {
          return copyFile(file, target);
        });
      }
      if (!modified) {
        return cb();
      }
      stat = dereference ? fs.stat : fs.lstat;
      return stat(target, function(err, stats) {
        if (!(file.mtime.getTime() > stats.mtime.getTime())) {
          return cb();
        }
        return copyFile(file, target);
      });
    });
  };
  copyFile = function(file, target) {
    var readStream, writeStream;
    readStream = fs.createReadStream(file.name);
    writeStream = fs.createWriteStream(target, {
      mode: file.mode
    });
    readStream.on('error', onError);
    writeStream.on('error', onError);
    if (transform) {
      transform(readStream, writeStream, file);
    } else {
      writeStream.on('open', function() {
        return readStream.pipe(writeStream);
      });
    }
    return writeStream.once('finish', function() {
      if (modified) {
        fs.utimesSync(target, file.atime, file.mtime);
      }
      return cb();
    });
  };
  rmFile = function(file, done) {
    return fs.unlink(file, function(err) {
      if (err) {
        return onError(err);
      }
      return done();
    });
  };
  onDir = function(dir) {
    var target;
    target = dir.name.replace(currentPath, targetPath);
    return isWritable(target, function(writable) {
      if (writable) {
        return mkDir(dir, target);
      }
      return copyDir(dir.name);
    });
  };
  mkDir = function(dir, target) {
    return fs.mkdir(target, dir.mode, function(err) {
      if (err) {
        return onError(err);
      }
      return copyDir(dir.name);
    });
  };
  copyDir = function(dir) {
    return fs.readdir(dir, function(err, items) {
      if (err) {
        return onError(err);
      }
      items.forEach(function(item) {
        return startCopy(path.join(dir, item));
      });
      return cb();
    });
  };
  onLink = function(link) {
    var target;
    target = link.replace(currentPath, targetPath);
    return fs.readlink(link, function(err, resolvedPath) {
      if (err) {
        return onError(err);
      }
      return checkLink(resolvedPath, target);
    });
  };
  checkLink = function(resolvedPath, target) {
    if (dereference) {
      resolvedPath = path.resolve(basePath, resolvedPath);
    }
    return isWritable(target, function(writable) {
      if (writable) {
        return makeLink(resolvedPath, target);
      }
      return fs.readlink(target, function(err, targetDest) {
        if (err) {
          return onError(err);
        }
        if (dereference) {
          targetDest = path.resolve(basePath, targetDest);
        }
        if (targetDest === resolvedPath) {
          return cb();
        }
        return rmFile(target, function() {
          return makeLink(resolvedPath, target);
        });
      });
    });
  };
  makeLink = function(linkPath, target) {
    return fs.symlink(linkPath, target, function(err) {
      if (err) {
        return onError(err);
      }
      return cb();
    });
  };
  isWritable = function(path, done) {
    return fs.lstat(path, function(err) {
      if (err) {
        if (err.code === 'ENOENT') {
          return done(true);
        }
        done(false);
      }
      return done(false);
    });
  };
  onError = function(err) {
    var errs;
    if (options.stopOnError) {
      return cback(err);
    }
    errs = [];
    if (!errs && options.errs) {
      errs = fs.createWriteStream(options.errs);
    }
    if (typeof errs.write === 'undefined') {
      errs.push(err);
    } else {
      errs.write(err.stack + '\n\n');
    }
    return cb();
  };
  cb = function(skipped) {
    if (!skipped) {
      running--;
    }
    finished++;
    if (started === finished && running === 0) {
      if (cback !== void 0) {
        if (errs) {
          return cback(errs);
        } else {
          return cback(null, finished);
        }
      }
    }
  };
  if (!callback) {
    cback = options;
    options = {};
  }
  basePath = options.cwd || process.cwd();
  targetPath = path.resolve(basePath, dest);
  filter = options.filter;
  rename = options.rename;
  transform = options.transform;
  clobber = options.clobber !== false;
  modified = options.modified;
  dereference = options.dereference;
  errs = null;
  started = 0;
  finished = 0;
  running = 0;
  limit = options.limit || ncp.limit || 16;
  limit = limit < 1 ? 1 : limit > 512 ? 512 : limit;
  if (!Array.isArray(sources)) {
    sources = [sources];
  }
  console.log(targetPath);
  results = [];
  for (i = 0, len = sources.length; i < len; i++) {
    s = sources[i];
    currentPath = path.resolve(basePath, s);
    results.push(startCopy(currentPath));
  }
  return results;
};

module.exports = ncp;
