inject = require "local-honk-di"


class Injector
  constructor: ->
    injector = new inject.Injector()
    if @getLibs?
      libs = @getLibs()
      for l of libs
        @[l] = injector.getInstance libs[l]


module.exports = Injector
