ensureOption = ( obj, name ) ->
  throw new Error "Missing option: #{name}" unless obj?[ name ]?

module.exports = {
  ensureOption
}
  