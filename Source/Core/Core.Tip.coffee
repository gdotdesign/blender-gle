###
---

name: Core.Tip

description: Tip.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Enabled

provides: Core.Tip

...
###
Core.Tip = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Enabled
  Binds:[
    'enter'
    'leave'
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'tip'
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'html', value
    }
    zindex: {
      value: 1
      setter: (value) ->
        @base.setStyle 'z-index', value
    }
    delay: {
      value: 0
    }
    location: {
      value: {x:'center',y:'center'}
    }
    offset: {
      value: 0
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  attach: (item) ->
    if @attachedTo?
      @detach()
    @attachedTo = document.id(item)
    @attachedTo.addEvent 'mouseenter', @enter
    @attachedTo.addEvent 'mouseleave', @leave
  detach: ->
    @attachedTo.removeEvent 'mouseenter', @enter
    @attachedTo.removeEvent 'mouseleave', @leave
    @attachedTo = null
  enter: ->
    if @enabled
      @over = true
      @id = ( ->
        if @over
          @show()
      ).bind(@).delay @delay
  leave: ->
    if @enabled
      if @id?
        clearTimeout(@id)
        @id = null
      @over = false
      @hide()
  ready: ->
    if @attachedTo?
      @base.position {
        relativeTo: @attachedTo
        position: @location
        offset: @offset
      }
  hide: ->
    @base.dispose()
  show: ->
    document.getElement('body').grab(@base)
}
