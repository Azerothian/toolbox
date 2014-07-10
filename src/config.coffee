CSON = require "cson-safe"
path = require "path"

fs = require "fs"


module.exports = class Config
  scope: "singleton"
  constructor: (fileName = "config.cson") ->
    @rootdir = process.cwd()
    configPath = path.join @rootdir, "/#{fileName}"
    data = fs.readFileSync configPath
    @cfg = CSON.parse data
    for i of @cfg
      if !@[i]?
        @[i] = @cfg[i]
      else
        throw "Config Variable already set... #{i} "
  getPath: (target) =>
    return path.join @rootdir, target
