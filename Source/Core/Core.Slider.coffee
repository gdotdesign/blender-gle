###
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled

provides: Core.Slider

...
###
Core.Slider = new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Slider.classes.base
    }
    bar: {
      value: GDotUI.Theme.Slider.classes.bar
      setter: (value, old) ->
        @progress.removeClass old
        @progress.addClass value
        value
    }
    reset: {
      value: off
    }
    steps: {
      value: 100
    }
    range: {
      value: [0,0]
    }
    
  }
  modeSetter: (value, old) ->
    @base.removeClass old
    @base.addClass value
    @base.set 'style', ''
    @base.setStyle 'position', 'relative'
    switch value
      when 'horizontal'
        @minSize = Number.from GDotUI.selectors[".#{@get('class')}.horizontal"]['min-width']
        @modifier = 'width'
        @drag.options.modifiers = {x: 'width',y:''}
        @drag.options.invert = false
        if not @size?
          size = Number.from GDotUI.selectors[".#{@get('class')}.horizontal"]['width']
        @set 'size', size
        @progress.set 'style', ''
        @progress.setStyles {
          position: 'absolute'
          top: 0
          bottom: 0
          left: 0
        } 
      when 'vertical'
        @minSize = Number.from GDotUI.selectors[".#{@get('class')}.vertical"]['min-height']
        @modifier = 'height'
        @drag.options.modifiers = {x: '',y: 'height'}
        @drag.options.invert = true
        if not @size?
          size = Number.from GDotUI.selectors[".#{@get('class')}.vertical"]['height']
        @set 'size', size
        @progress.set 'style', ''
        @progress.setStyles {
          position: 'absolute'
          bottom: 0
          left: 0
          right: 0
        }
    if @base.isVisible()
      @set 'value', @value
    value
    
  valueSetter: (value) ->
    value = Number.from value
    if !@reset
      percent = Math.round((value/@steps)*100)
      if value < 0
        @progress.setStyle @modifier, 0
        value = 0
      if @value > @steps
        @progress.setStyle @modifier, @size
        value = @steps
      if not(value < 0) and not(value > @steps)
        @progress.setStyle @modifier, (percent/100)*@size
    value
  valueGetter: ->
    if @reset
      @value
    else
      Number.from(@progress.getStyle(@modifier))/@size*@steps
  sizeSetter: (value, old) ->
    if !value?
      value = old
    if @minSize > value
      value = @minSize
    @base.setStyle @modifier, value
    @progress.setStyle @modifier, if @reset then value/2 else @value/@steps*value
    value
  onDrag: (el,e) ->
    if @enabled
      pos = Number.from el.getStyle(@modifier)
      offset = Math.round((pos/@size)*@steps)-@lastpos
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if pos > @size
        el.setStyle @modifier, @size
        pos = @size
      else
        if @reset
          @value += offset
      if not @reset
        @value = Math.round((pos/@size)*@steps)
      @fireEvent 'step', @value
      @update()
    else
      el.setStyle @modifier, @disabledTop
  create: ->
    @addAttributes {
      mode: {
        value: 'horizontal'
        setter: @modeSetter
      }
      value: {
        value: 0
        setter: @valueSetter
        getter: @valueGetter
      }
      size: {
        setter: @sizeSetter
      }  
    }
    @progress = new Element "div"
         
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base}
    @drag.addEvent 'beforeStart', ( (el,e) ->
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if not @enabled
        @disabledTop = el.getStyle @modifier
    ).bind @
    @drag.addEvent 'complete', ( (el,e) ->
      if @reset
        if @enabled
          el.setStyle @modifier, @size/2+"px"
      @fireEvent 'complete'
    ).bind @
    @drag.addEvent 'drag', @onDrag.bind @
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      if @enabled
        @set 'value', @value+Number.from(e.wheel)
        @fireEvent 'step', @value
    ).bind @

}
