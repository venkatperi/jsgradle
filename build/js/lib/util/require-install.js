var NPM, _require, dep_keys, exec, execFile, execFileSync, extend, npmInstall, npmInstallSync, ref, spawnSync,
  slice = [].slice,
  hasProp = {}.hasOwnProperty;

ref = require('child_process'), spawnSync = ref.spawnSync, execFile = ref.execFile, execFileSync = ref.execFileSync;

NPM = '/usr/local/bin/npm';

dep_keys = ['devDependencies', 'dependencies'];

extend = function() {
  var dest, i, item, items, k, len, v;
  dest = arguments[0], items = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  for (i = 0, len = items.length; i < len; i++) {
    item = items[i];
    for (k in item) {
      if (!hasProp.call(item, k)) continue;
      v = item[k];
      dest[k] = v;
    }
  }
  return dest;
};

exec = function(cmd, args, opts, cb) {
  if (args == null) {
    args = [];
  }
  if (opts == null) {
    opts = {};
  }
  return execFile(cmd, args, opts, function(e, stdout, stderr) {
    if (e) {
      return cb((function() {
        switch (e.code) {
          case 'ENOENT':
            return new Error(cmd + ": command not found");
          default:
            return e;
        }
      })());
    }
    return cb(null, {
      stdout: stdout,
      stderr: stderr
    });
  });
};

npmInstall = function(pkg, args, cb) {
  args.unshift(pkg);
  return exec(NPM, args, {}, cb);
};

npmInstallSync = function(pkg, args) {
  args.unshift(pkg);
  args.unshift('install');
  return spawnSync(NPM, args);
};

_require = function(pkg, opts) {
  var args, e, error;
  if (opts == null) {
    opts = {
      save: true,
      dev: true
    };
  }
  try {
    return require(pkg);
  } catch (error) {
    e = error;
    console.log("Installing " + pkg);
    args = [];
    if (opts.save && opts.dev) {
      args.push('--save-dev');
    } else if (opts.save) {
      args.push('--save');
    }
    npmInstallSync(pkg, args);
    return require(pkg);
  }
};

module.exports = _require;
