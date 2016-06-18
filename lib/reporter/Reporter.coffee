_ = require 'lodash'

events = [
  'script:initialize:start',
  'script:initialize:end',
  'script:configure:start',
  'script:configure:end',
  'script:afterEvaluate:start',
  'script:afterEvaluate:end',
  'script:execute:start',
  'script:execute:end',

  'project:initialize:start',
  'project:initialize:end',
  'project:configure:start',
  'project:configure:end',
  'project:afterEvaluate:start',
  'project:afterEvaluate:end',
  'project:execute:start',
  'project:execute:end',

  'task:initialize:start',
  'task:initialize:end',
  'task:configure:start',
  'task:configure:end',
  'task:afterEvaluate:start',
  'task:afterEvaluate:end',
  'task:execute:start',
  'task:execute:end',

  'action:initialize:start',
  'action:initialize:end',
  'action:configure:start',
  'action:configure:end',
  'action:execute:start',
  'action:execute:end' ]

class Reporter
  constructor : ( opts = {} ) ->

  listenTo : ( obj ) =>
    obj.on 'error', @onError
    for e in events
      handler = 'on' + _.map(e.split(':'), ( x ) -> _.upperFirst x).join('')
      obj.on e, @[ handler ] if @[ handler ]?

module.exports = Reporter