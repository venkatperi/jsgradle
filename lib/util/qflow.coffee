q = require('q')

###*
# Call `fn`, which returns a promise, on each item in `array`.
###

Q = {}
Q.each = ( array, fn ) ->
  array.reduce((( promise, each ) ->
    promise.then ->
      fn each
  ), q()).then ->
    # mask last value
    return

###*
# Call `fn`, which returns a promise, on each item in `array`, returning new
# array.
###

Q.map = ( array, fn ) ->
  mappedArray = []
  q.each(array, (( each ) ->
    fn(each).then ( item ) ->
      mappedArray.push item
      return
  ), q()).then ->
    mappedArray
  return

find = ( array, fn, current ) ->
  Q.until ->
    fn(array[ current ]).then ( result ) ->
      if result
        return array[ current ]
      current += 1
      if current >= array.length
        return true
      # break the loop
      return

###*
# Find first object in `array` satisfying the condition returned by the
# promise returned by `fn`.
###

Q.find = ( array, fn ) ->
  find(array, fn, 0).then ( result ) ->
    if result == true
      return undefined
    result

###*
# Loop until the promise returned by `fn` returns a truthy value.
###

Q.until = ( fn ) ->
  fn().then ( result ) ->
    if result
      return result
    Q.until fn

module.exports = Q