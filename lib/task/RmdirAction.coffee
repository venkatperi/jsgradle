_ = require 'lodash'
Q = require 'q'
rek = require 'rekuire'
Action = require './Action'
{rmdir} = rek 'fileOps'
{ensureOptions} = rek 'validate'
log = rek('logger')(require('path').basename(__filename).split('.')[ 0 ])

class RmdirAction extends Action

  constructor : ( opts = {} ) ->
    {@dirs} = ensureOptions opts, 'dirs'
    super opts

  exec : ( resolve ) =>
    resolve Q.all(_.map @dirs,
      ( x ) =>
        @task.didWork = true
        rmdir x
    )

module.exports = RmdirAction
    


