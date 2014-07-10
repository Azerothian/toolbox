Promise = require "bluebird"
socketio = require "socket.io"
tbxutil = require "./util"
{log, argsToArray} = tbxutil

class SiocServer
  @scope: "singleton"
  constructor: () ->
    @logic = {}

  init: (@io) =>
    @io.on "connection", @onConnection

  registerLogic: (name, logic) =>
    @logic[name] = logic

  onConnection: (err, socket) =>
    log "onConnection - init", err
    lg = {}
    for l of @logic
      lg[l] = new @logic[l]
      lg[l].socket = socket
      #lg[l].emit = @emitHook socket
      events = lg[l].getEvents()
      for e of events
        socket.on e, (msg) =>
          #log "onConnection - socket.on", msg
          events[e].apply(lg[l], msg.args).then () =>
            data = [msg.id].concat argsToArray(arguments)
            #log "onConnection - apply", data, arguments
            socket.emit.apply socket, data
          , () =>
            log "reject"

    #socket.on "disconnect", () =>
      #@sockets = @sockets.filter (s) -> s isnt socket


#  emitHook: (socket) =>
#    return () =>
#      log "emit hook not defined"




module.exports = Sioc
