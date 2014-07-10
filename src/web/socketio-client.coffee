Promise = require "bluebird"
io = require "socket.io-client"
{log, uuid} = require "../util"

class Client
  @scope: "singleton"
  constructor: (@onReady) ->
    @connected = false

  listen: (address = "http://127.0.0.1:4011/") =>
    return new Promise (resolve, reject) =>
      @socket = io.connect address
      @socket.on "connect", () =>
        @connected = true
        return resolve()


  emit: (event, args...) =>
    return new Promise (resolve, reject) =>
      id = uuid()
      hook = () =>
        #log "emit commit"
        @socket.off id, hook
        resolve.apply undefined, arguments
      #log "emit on", id
      @socket.on id, hook
      @socket.emit event, { id: id, args: args }


module.exports = Client
