CSON = require "cson"
path = require "path"

module.exports = class Config
  scope: "singleton"
  constructor: (fileName = "config.cson") ->
    @rootdir = process.cwd()
    configPath = path.join rootdir, "/#{fileName}"
    @cfg = CSON.parseFileSync configPath
    for i of cfg
      if !@[i]?
        @[i] = @cfg[i]
      else
        throw "Config Variable already set... #{i} "
  getPath: (target) =>
    return path.join @rootdir, target
