###
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Iterable.List

provides: Core.Slot

todo: horizontal/vertical
...
###
Core.Slot = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'slot'
    }
  }
  Binds:[
    'check'
    'complete'
    'update'
    'mouseWheel'
  ]
  Delegates:{
    'list':[
      'addItem'
      'removeAll'
      'removeItem'
    ]
  }
  create: ->
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @overlay.addEvent 'mousewheel',@mouseWheel
    
    @overlay.setStyles {
      'position': 'absolute'
      'top': 0
      'left': 0
      'right': 0
      'bottom': 0
    }
    
    @list = new Iterable.List()
    @list.base.addEvent 'addedToDom', @update
    @list.addEvent 'selectedChange', (item) =>
      @update()
      @fireEvent 'change', item.newVal
    @list.setStyle 'position', 'relative'
    @list.setStyle 'top', '0'
    
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart', =>
      if not @enabled
        @disabledTop = @list.base.getStyle 'top' 
      @list.base.removeTransition()
    @drag.addEvent 'complete', =>
      @dragging = off
      @update()
  ready: ->
    @base.adopt @list, @overlay
  check: (el,e) ->
    if @enabled
      @dragging = on
      lastDistance = 1000
      lastOne = null
      @list.children.each (item,i) =>
        distance = -item.base.getPosition(@base).y + @base.getSize().y/2
        if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
          @list.set 'selected', item
    else
      el.setStyle 'top', @disabledTop
  mouseWheel: (e) ->
    if @enabled
      e.stop()
      if @list.selected?
        index = @list.children.indexOf @list.selected
      else
        if e.wheel is 1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.children.length 
        @list.set 'selected', @list.children[index+e.wheel]
      if index+e.wheel < 0
        @list.set 'selected', @list.children[@list.children.length-1]
      if index+e.wheel > @list.children.length-1
        @list.set 'selected', @list.children[0]
  update: ->
    if not @dragging
      @list.base.addTransition()
      if @list.selected?
        @list.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}
