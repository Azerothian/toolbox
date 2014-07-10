log = () ->

if console?
  if Function?
    if Function.prototype?
      if Function.prototype.bind?
        log = Function.prototype.bind.call(console.log, console)
      else
        log = () ->
          Function.prototype.apply.call(console.log, console, arguments)
  else if console.log?
    if console.log.apply?
      log = () ->
        console.log.apply console, arguments


module.exports = {
  log: log
  # RFC1422-compliant Javascript UUID function. Generates a UUID from a random
  # number (which means it might not be entirely unique, though it should be
  # good enough for many uses). See http://stackoverflow.com/questions/105034
  uuid: ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c is 'x' then r else (r & 0x3|0x8)
      v.toString(16)
    )
  getType: (obj) ->
    if obj == undefined or obj == null
      return String obj
    classToType = {
      '[object Boolean]': 'boolean',
      '[object Number]': 'number',
      '[object String]': 'string',
      '[object Function]': 'function',
      '[object Array]': 'array',
      '[object Date]': 'date',
      '[object RegExp]': 'regexp',
      '[object Object]': 'object'
    }
    return classToType[Object.prototype.toString.call(obj)]
  argsToArray: (args) ->
    a = []
    for i of args
      log "argsToArray", i, args[i]
      a.push args[i]
    return a
}
