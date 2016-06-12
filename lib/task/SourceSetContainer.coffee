rek = require 'rekuire'
prop = rek 'prop'
Collection = require '../util/Collection'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class SourceSetContainer extends Collection
  prop @, 'root',
    get : ->
      root = @
      while (root.parent?)
        root = root.parent
      root

  constructor : ( opts = {} ) ->
    super opts
    @parent = opts.parent or throw new Error "Missing option: parent"
    @methods = []
    @on 'add', ( name ) =>
      @methods.push name
      @[ name ] = ( f ) =>
        log.v "configuring #{name}"
        f = f[ 0 ] if Array.isArray f
        @root.callScriptMethod @.get(name), f

  hasMethod : ( name ) =>
    name in @methods

module.exports = SourceSetContainer