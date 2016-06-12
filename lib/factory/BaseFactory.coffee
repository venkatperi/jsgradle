{AbstractFactory} = require 'coffee-dsl'

class BaseFactory extends AbstractFactory
  
  constructor : ( {@script} ={} ) ->
    throw new Error "Missing option: script" unless @script?
    
  setChild : ( builder, parent, child ) => parent.setChild? child
    
  onNodeCompleted : ( builder, parent, node ) => node.onCompleted? parent


module.exports = BaseFactory