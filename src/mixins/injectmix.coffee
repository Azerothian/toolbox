inject = require "local-honk-di"

module.exports = {

  componentWillMount: ->
    if @getLibs?
      libs = @getLibs()
      for l of libs
        @[l] = inject.getInstance libs[l]
}
