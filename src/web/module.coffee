class Module
  getEvents: () =>
    rs = []
    for i in @events
      rs.push {
        name: "#{@name}/#{i}"
        func: @[i]
        express:
          requestType: "post"
          responseType: "json"
        socketio: {}
      }
    return rs


module.exports = Module
