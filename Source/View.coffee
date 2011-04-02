###
---

name: Blender.View

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Core.Slider
  - Blender.Corner
  - Blender.Toolbar

provides: Blender.View

...
###
Blender.View = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-view'
    }
    top: {
      setter: (value) ->
        value = Number.eval value, window.getSize().y
        @base.setStyle 'top', value+1
        value
    }
    width: {
      getter: ->
        @get('right')-@get('left')
    }
    height: {
      getter: ->
        @get('bottom')-@get('top')
    }
    left: {
      setter: (value) ->
        value = Number.eval value, window.getSize().x
        @base.setStyle 'left', value
        value
    }
    right: {
      setter: (value) ->
        value = Number.eval value, window.getSize().x
        @base.setStyle 'right',  window.getSize().x-value+1
        value
    }
    restrains: {
      value: {top: no, left: no, right: no, bottom: no}
    }
    bottom: {
      setter: (value) ->
        value = Number.eval value, window.getSize().y
        @base.setStyle 'bottom', window.getSize().y-value
        value
    }
    content: {
      value: null
      setter: (newVal,oldVal)->
        if oldVal
          @removeChild oldVal
          if oldVal.toolbar?
            @toolbar.removeChild oldVal.toolbar
        @addChild newVal, 'top'
        if newVal.toolbar?
          @toolbar.addChild newVal.toolbar
        newVal
    }
    stack: {
      setter: (value) ->
        @fireEvent 'content-change', value
        value
    }
  }
  resize: ->
    winsize = window.getSize()
    horizpercent = winsize.x/@windowSize.x
    vertpercent = winsize.y/@windowSize.y
    @windowSize = winsize
    @set 'right', Math.floor @right*horizpercent
    @set 'left', Math.floor @left*horizpercent
    @set 'top', Math.floor @top*vertpercent
    @set 'bottom', Math.floor @bottom*vertpercent
  update: ->
    width = @base.getSize().x-10
    if @slider.base.isVisible()
      width -= 20
    @children.each ((child) ->
      child.set 'size', width
    ).bind @
    @slider.set 'size', @base.getSize().y-60
    if @base.getSize().y < @base.getScrollSize().y
      @slider.show()
    else
      @slider.hide()
  create: ->
    @windowSize = window.getSize()
    @addEvent 'rightChange', (o)->
      a = @hooks.right
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'right', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'left', o.newVal
    @addEvent 'topChange', (o)->
      a = @hooks.top
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'top', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'bottom', o.newVal
    @addEvent 'bottomChange', (o)->
      a = @hooks.bottom
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'bottom', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'top', o.newVal
    @addEvent 'leftChange', (o)->
      a = @hooks.left
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'left', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'right', o.newVal
    @hooks = {}
    @slider = new Core.Slider({steps:100,mode:'vertical'})
    @slider.minSize = 0
    @slider.base.setStyle 'min-height', 0
    @toolbar = new Blender.Toolbar()
    @toolbar.select.addEvent 'change', ((e)->
      @fireEvent 'content-change', e
    ).bind @
    @base.adopt @slider, @toolbar

    @position = {x:0,y:0}
    @size = {w:0,h:0}
    @topLeftCorner = new Blender.Corner({class:'topleft'})
    @topLeftCorner.addEvent 'directionChange',((dir,e) ->
      e.stop()
      if e.control
        if (dir is 'left' or dir is 'right') 
          @fireEvent 'split',[@,'horizontal']
        if (dir is 'bottom' or dir is 'top')
          @fireEvent 'split',[@,'vertical']
      else
        if (dir is 'bottom' or dir is 'top') and @get('top') isnt 0
          @drag.startpos = {y:Number.from(@base.getStyle('top'))}
          @drag.options.modifiers = {x:null,y:'top'}
          @drag.options.invert = true
          @drag.start(e)
        
        if (dir is 'left' or dir is 'right') and @get('right') isnt window.getSize().x
          @drag.startpos = {x:Number.from(@get('right'))}
          @drag.options.modifiers = {x:'right',y:null}
          @drag.options.invert = true
          @drag.start(e)
    ).bind @
    @bottomRightCorner = new Blender.Corner({class:'bottomleft'})
    @bottomRightCorner.addEvent 'directionChange',((dir,e) ->
      if (dir is 'bottom' or dir is 'top') and  @get('bottom') isnt window.getSize().y
        @drag.startpos = {y:Number.from(@get('bottom'))}
        @drag.options.modifiers = {x:null,y:'bottom'}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'left' or dir is 'right') and  @get('left') isnt 0
        @drag.startpos = {x:Number.from(@base.getStyle('left'))}
        @drag.options.modifiers = {x:'left',y:null}
        @drag.options.invert = true
        @drag.start(e)
    ).bind @
    @adoptChildren @topLeftCorner, @bottomRightCorner
    @drag = new Drag @base, {modifiers:{x:'',y:''}, style:false}
    @drag.detach()
    @drag.addEvent 'drag', ((el,e) ->
      if @drag.options.modifiers.x?
        offset = @drag.mouse.start.x-@drag.mouse.now.x
        if @drag.options.invert
          offset = -offset
        posx = offset+@drag.startpos.x
        @set @drag.options.modifiers.x, if posx > 0 then posx else 0
      if @drag.options.modifiers.y?
        offset = @drag.mouse.start.y-@drag.mouse.now.y
        if @drag.options.invert
          offset = -offset
        posy = offset+@drag.startpos.y
        @set @drag.options.modifiers.y, if posy > 0 then posy else 0
    ).bind @
  check: ->
}
