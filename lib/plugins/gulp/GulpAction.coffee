rek = require 'rekuire'
Action = rek 'Action'

class CoffeeAction extends Action

  init : ( opts = {} ) =>
    @gulp = opts.gulp
    @taskName = opts.taskName

  exec : ( resolve, reject ) =>
    @gulp.start @taskName, ( err, res ) ->
      return reject err if err?
      resolve res

module.exports = CoffeeAction
    


