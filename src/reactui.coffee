React = require "react"

if window?
  window.React = React
React.initializeTouchEvents true


{div} = React.DOM

class ReactUI
  @scope: "singleton"
  constructor: () ->
    console.log "CREATE REACTUI"
    @components = {}

  add: (name, component) =>
    if @components[name]?
      #todo: log "warning component already set", trigger remove?
      @remove name

    @components[name] = component
    @update()
  remove: (name) =>
    if @components[name]?
      delete @components[name]
    @update()

  @getBaseReact: (manager) =>
    return React.createClass {
      render: ->
        args = [{ className: "row" }]
        for component of manager.components
          args.push manager.components[component]()

        return div.apply undefined, args
    }
  getReact: () =>
    return ReactUI.getBaseReact @

  onDocumentReady: () =>
    return new Promise (resolve, reject) =>
      if $("#react-root").length is 0
        $("body").append $("<div id='react-root'></div>")
      @reactMain = React.renderComponent ReactUI.getBaseReact(@)(), document.getElementById('react-root')
      return resolve()

  update: () =>
    if @reactMain?
      @reactMain.forceUpdate()

module.exports = ReactUI
