{spawnSync, execFile, execFileSync} = require('child_process')

NPM = '/usr/local/bin/npm'
dep_keys = [ 'devDependencies', 'dependencies' ]

extend = ( dest, items... ) ->
  for item in items
    for own k,v of item
      dest[ k ] = v
  dest

exec = ( cmd, args = [], opts = {}, cb ) ->
  execFile cmd, args, opts, ( e, stdout, stderr ) ->
    if e
      return cb switch e.code
        when 'ENOENT' then new Error "#{cmd}: command not found"
        else
          e
    cb null, stdout : stdout, stderr : stderr

npmInstall = ( pkg, args, cb ) ->
  args.unshift pkg
  exec NPM, args, {}, cb

npmInstallSync = ( pkg, args ) ->
  args.unshift pkg
  args.unshift 'install'
  spawnSync NPM, args

_require = ( pkg, opts = { save : true, dev : true } ) ->
  try
    require pkg
  catch e
    console.log "Installing #{pkg}"
    args = []
    if opts.save and opts.dev
      args.push '--save-dev'
    else if opts.save
      args.push '--save'

    npmInstallSync pkg, args
    return require pkg

module.exports = _require
