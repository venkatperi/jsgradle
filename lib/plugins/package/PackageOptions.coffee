_ = require 'lodash'
rek = require 'rekuire'
{readFileSync} = rek 'fileOps'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

properties = [ 'name', 'description', 'keywords', 'preferGlobal',
  'homepage', 'bugs', 'license', 'author',
  'contributors', 'main', 'bin', 'repository',
  'scripts', 'man', 'dist', 'gitHead',
  'maintainers'
]

class PackageOptions
  constructor : ->

  hasProperty : ( name ) =>
    log.i 'hasProperty', name
    name in properties

  getProperty : ( name ) =>
    log.i 'getProperty', name
    @pkg[ name ]

  setProperty : ( name, value ) =>
    log.i 'setProperty', name, value
    @pkg[ name ] = value

  load : ( file ) =>
    @filename = file
    pkg = JSON.parse readFileSync file, 'utf8'
    @pkg = {}
    @original = {}
    _.extend @pkg, pkg
    _.extend @original, pkg

module.exports = PackageOptions