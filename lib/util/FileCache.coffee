CacheSwap = require 'cache-swap'
rek = require 'rekuire'
conf = rek 'conf'
Q = require 'q'
_ = require 'lodash'
path = require 'path'

methods =
  has : 'hasCached'
  set : 'addCached'
  get : 'getCached'
  delete : 'removeCached'

class FileCache extends CacheSwap
  constructor : ( opts = {} ) ->
    tmpDir = conf.get 'project:cache:cacheDir'
    opts = _.extend {}, tmpDir : tmpDir, opts
    super opts
    @category = opts.category or 'default'
    @cacheDir = path.join tmpDir, opts.cacheDirName, @category
    for own k,v of methods
      do ( k, v ) =>
        @[ k ] = ( args... ) =>
          Q.nmapply @, v, [ @category ].concat args...

module.exports = FileCache