###
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Iterable.List

provides: Core.Slot

todo: horizontal/vertical, interfaces.size etc
...
###
Core.Slot = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Enabled
  Attributes: {
    class: {
      value: GDotUI.Theme.Slot.class
    }
  }
  Binds:[
    'check'
    'complete'
  ]
  Delegates:{
    'list':[
      'addItem'
      'removeAll'
      'select'
    ]
  }
  create: ->
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @list = new Iterable.List()
    @list.base.addEvent 'addedToDom', @update.bind @
    @list.addEvent 'selectedChange', ((item) ->
      @update()
      @fireEvent 'change', item.newVal
    ).bind @
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    @list.base.setStyle 'position', 'relative'
    @list.base.setStyle 'top', '0'
    @overlay.setStyles {
      'position': 'absolute'
      'top': 0
      'left': 0
      'right': 0
      'bottom': 0
    }
    @overlay.addEvent 'mousewheel',@mouseWheel.bind @
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart',( ->
      if not @enabled
        @disabledTop = @list.base.getStyle 'top' 
      @list.base.removeTransition()
    ).bind @
    @drag.addEvent 'complete', ( ->
      @dragging = off
      @update()
    ).bind @
  ready: ->
    @base.adopt @list, @overlay
  check: (el,e) ->
    if @enabled
      @dragging = on
      lastDistance = 1000
      lastOne = null
      @list.items.each ((item,i) ->
        distance = -item.base.getPosition(@base).y + @base.getSize().y/2
        if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
          @list.set 'selected', item
      ).bind @
    else
      el.setStyle 'top', @disabledTop
  mouseWheel: (e) ->
    if @enabled
      e.stop()
      if @list.selected?
        index = @list.items.indexOf @list.selected
      else
        if e.wheel is 1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.items.length 
        @list.set 'selected', @list.items[index+e.wheel]
      if index+e.wheel < 0
        @list.set 'selected', @list.items[@list.items.length-1]
      if index+e.wheel > @list.items.length-1
        @list.set 'selected', @list.items[0]
  update: ->
    if not @dragging
      @list.base.addTransition()
      if @list.selected?
        @list.base.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}
