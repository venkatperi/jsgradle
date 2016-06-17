_ = require 'lodash'
rek = require 'rekuire'
BaseObject = rek 'BaseObject'
semver = require 'semver'

allTrue = ( args... ) ->
  !_.some args, ( x ) -> x is false

class Dependency extends BaseObject
  @_addProperties
    required : [ 'name', 'version' ]
    optional : [ 'context', 'group' ]

  toString : =>
    "#{@name}:#{@version}"

  @valid : ( args... ) ->
    allTrue args.length is 2, _.isString args[ 0 ],
      _.isString args[ 1 ], args[ 0 ].indexOf(':') < 0,
        semver.valid(args[ 1 ])

  @create : ( args... ) ->
    return if args.length is 0
    if @valid args...
      return new Dependency name : args[ 0 ], version : args[ 1 ]
    a = args[ 0 ]
    return unless a.indexOf(':') > 0
    Dependency.create.apply Dependency, a.split ':'

module.exports = Dependency