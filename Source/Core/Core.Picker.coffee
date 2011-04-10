###
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled

provides: Core.Picker
...
###
Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
  ]
  Binds: ['show','hide','delegate']
  Attributes: {
    class: {
      value: 'blender-picker'
    }
    offset: {
      value: 0
      setter: (value) ->
        value
    }
    position: {
      value: {x:'auto',y:'auto'}
      validator: (value) ->
        value.x? and value.y?
    }
    content: {
      value: null
      setter: (value, old)->
        if old?
          if old["$events"]
            old.removeEvent 'change', @delegate
          @removeChild old
        @addChild value
        if value["$events"]
          value.addEvent 'change', @delegate
        value
    }
    picking: {
      value: 'picking'
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  ready: ->
    @base.position {
      relativeTo: @attachedTo
      position: @position
      offset: @offset
    }
  attach: (el,auto) ->
    auto = if auto? then auto else true
    if @attachedTo?
      @detach()
    @attachedTo = el
    if auto
      el.addEvent 'click', @show
  detach: ->
    if @attachedTo?
      @attachedTo.removeEvent 'click', @show
      @attachedTo = null
  delegate: ->
    if @attachedTo?
      @attachedTo.fireEvent 'change', arguments
  show: (e,auto) ->
    auto = if auto? then auto else true
    document.body.grab @base
    if @attachedTo?
      @attachedTo.addClass @picking
    if e? then if e.stop? then e.stop()
    if auto
      @base.addEvent 'outerClick', @hide
  hide: (e,force) ->
    if force?
      if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
    else if e?
      if @base.isVisible() and not @base.hasChild(e.target)
        if @attachedTo?
          @attachedTo.removeClass @picking
        @base.dispose()
}
