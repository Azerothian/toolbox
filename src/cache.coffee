moment = require "moment"
{log} = require "./util"


class Cache
  constructor: () ->
    @ttl = {}
    @cache = {}
    setInterval @check, 5000

  set: (key, value, ttl, ttlType = "ms") =>
    if ttl?
      @setTtl key, ttl, ttlType
    @cache[key] = value

  setTtl: (key, ttl, ttlType = "ms") =>
    @ttl[key] = {
      expire: moment().add ttlType, ttl
      ttl: ttl
      ttlType: ttlType
    }

  get: (key) =>
    return @cache[key]

  check: () =>
    for k of @ttl
      if moment().isAfter @ttl[k].expire
        log "cleaning cache #{k}"
        delete @cache[k]
        delete @ttl[k]
  touch: (key, ttl, ttlType = "ms") =>
    if @ttl[key]?
      if !ttl?
        ttl = @ttl[key].ttl
        ttlType = @ttl[key].ttlType
      @setTtl key, ttl, ttlType


module.exports = Cache
