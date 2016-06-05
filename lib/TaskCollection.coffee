_ = require 'lodash'
{EventEmitter} = require 'events'

class TaskCollection extends EventEmitter
  constructor : ( opts = {} ) ->
    @tasks = {}

  add : ( tasks... ) =>
    for t in tasks
      @tasks[ t.name ] = t
      @emit 'add', t
      @

  has : ( name ) => @tasks[ name ]?

  getByName : ( name ) => @tasks[ name ]

  matching : ( f ) =>  _.filter @tasks, f

module.exports = TaskCollection