rek = require 'rekuire'
Action = rek 'lib/task/Action'
prop = rek 'prop'
{writeFile} = rek 'fileOps'
{ensureOptions} = rek 'validate'

class UpdatePkgAction extends Action

  init : ( opts = {} )=>
    {@filename, @pkg} = ensureOptions opts, 'filename', 'pkg'

  exec : ( resolve ) =>
    data = JSON.stringify @pkg, null, 2
    resolve writeFile @filename, data, 'utf8'
    .then => @task.didWork++

module.exports = UpdatePkgAction