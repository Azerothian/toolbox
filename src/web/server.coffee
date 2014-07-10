{log, argsToArray} = require "../util"

express = require "express"
http = require "http"
socketio = require "socket.io"
bodyParser = require "body-parser"
Promise = require "bluebird"

# TODO: add session management

class Server
  constructor: () ->
    @modules = []
    @expressApp = express()
    @httpServer = http.createServer @expressApp
    @io = socketio @httpServer

    #expose express's use func? not sure if this will work without using apply!?
    @use = () =>
      @expressApp.use.apply @expressApp, arguments
    @use bodyParser.json()
    @use bodyParser.urlencoded { extended: true }

  register: (cls) =>
    #return new Promise (resolve, reject) =>
    @modules.push cls
    #  return resolve()

  static: (staticPath) =>
    @use express.static staticPath

  init: (@config = { port: 2122 }) =>
    return new Promise (resolve, reject) =>
      @initExpress()
      @io.on "connection", @onSocketConnection
      @httpServer.listen @config.port
      log "listening on #{@config.port}"
      return resolve()

  initExpress: () =>
    for m in @modules
      events = m.getEvents()
      for e in events
        if e.express
          if !e.express.requestType?
            e.express.requestType ="all"
          if !e.express.responseType?
            e.express.responseType = "json"
          @expressApp[e.express.requestType] "/#{e.name}", @expressHook(e)


  expressHook: (event) ->
    return (req, res) ->
      return event.func({ req: req, res: res }, req.body).then () ->
        res[e.express.responseType] arguments
      , () ->
        log "express hook rejected - closing connection"
        #todo: proper err response
        res.send "false"

  onSocketConnection: (socket) =>
    log "onSocketConnection - start"
    for m in @modules
      events = m.getEvents()
      for e in events
        if e.socketio
          socket.on "/#{e.name}", (msg) ->
            log "onSocketConnection - socket.on #{e.name}"
            events[e].func.apply(m, msg.args).then () ->
              data = [msg.id].concat argsToArray(arguments)
              log "onSocketConnection - socket.on emit #{e.name}"
              socket.emit.apply socket, data
            , () ->
              log "onSocketConnection - socket.on rejected #{e.name}"




module.exports = Server


### Example Module

class User
  constructor: ->

  getEvents: () =>
    [
      {
        name: "user/create"
        func: @createUser
        express:
          requestType: "get"
          responseType: "json"
        socketio: {}
      }
    ]
  createUser: () ->
    return new Promise (resolve, reject) ->

      return resolve()

###
