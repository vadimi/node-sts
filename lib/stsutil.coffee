class StsUtil

  # escapes special regexp symbols to pass string into regex
  @escapeRegex = (source) ->
    return source unless source? or source.length isnt 0
    source.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&')

module.exports = StsUtil