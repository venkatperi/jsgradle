class CoffeeOptions
  constructor : ->
    @bare = false
    @sourceMap = false
    @literate = false

  hasProperty : ( name ) =>
    name in [ 'bare', 'sourceMap', 'literate' ]

module.exports = CoffeeOptions