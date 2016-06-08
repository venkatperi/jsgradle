Plugin = require './Plugin'
log = require('../util/logger') 'CoffeePlugin'

class CoffeePlugin extends Plugin
  constructor : ->
    log.v 'ctor()'
    @options =
      bare : false
      sourceMap : false
      literate : false

  apply : ( project ) =>
    return if @configured
    super project
    project.extensions.add 'coffeescript', @options

    project.task 'compileCoffee', null, ( t ) =>
      log.v 'configuring'
      t.doFirst =>

module.exports = CoffeePlugin