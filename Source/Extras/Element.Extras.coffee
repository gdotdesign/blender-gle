###
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
    @setAttribute 'checked', value
    if @on? and @off?
      if value
        @on()
      else
        @off()
}
( ->
  Number.implement {
    inRange: (center,range) ->
      if center-range < @ < center+range
        true
      else
        false
  }
  Number.eval = (string,size) ->
    Number.from(eval(String.from(string).replace /(\d*)\%/g, (match,str) ->
      (Number.from(str)/100)*size
    ))
)()
( ->
  Color.implement {
    type: 'hex'
    alpha: 100
    setType: (type) ->
      @type = type
    setAlpha: (alpha) ->
      @alpha = alpha
    hsvToHsl: ->
      h = @hsb[0]
      s = @hsb[1]
      v = @hsb[2]
      l = (2 - s / 100) * v / 2;
      hsl = [
        h
        s * v / (if l < 50 then l * 2 else 200 - l * 2)
        l
      ]
      if isNaN(hsl[1]) then hsl[1] = 0
      hsl
    format: (type) ->
      if type then @setType(type)
      switch @type
        when "rgb"
          String.from "rgb(#{@rgb[0]}, #{@rgb[1]}, #{@rgb[2]})"
        when "rgba"
          String.from "rgba(#{@rgb[0]}, #{@rgb[1]}, #{@rgb[2]}, #{@alpha/100})"
        when "hsl"
          @hsl = @hsvToHsl()
          String.from "hsl(#{@hsl[0]}, #{Math.round(@hsl[1])}%, #{Math.round(@hsl[2])}%)"
        when "hsla"
          @hsl = @hsvToHsl()
          String.from "hsla(#{@hsl[0]}, #{Math.round(@hsl[1])}%, #{Math.round(@hsl[2])}%, #{@alpha/100})"
        when "hex"
          String.from @hex
  }
)()
( ->
  oldPrototypeStart = Drag::start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()
(->
  Element.Events.outerClick = {
    base: 'mousedown'
    condition: (event) ->
      event.stopPropagation()
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
      window.addEvent 'outer', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
      window.removeEvent 'outer', fn
  }
  Element.implement {
    replaceClass: (newClass,oldClass) ->
      @removeClass oldClass
      @addClass newClass
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
    oldPosition: Element::position
    position: (options) ->
      if options.relativeTo isnt undefined
        op = {
          relativeTo: document.body
          position: {x:'center',y:'center'}
        }
        options = Object.merge op, options
        winsize = window.getSize()
        winscroll = window.getScroll()
        asize = options.relativeTo.getSize()
        position = options.relativeTo.getPosition()
        size = @getSize()
        if options.position.x is 'auto' 
          if (position.x+size.x+asize.x) > (winsize.x-winscroll.x) then options.position.x = 'left' else options.position.x = 'right'          
        if options.position.y is 'auto'
          if (position.y+size.y+asize.y) > (winsize.y-winscroll.y) then options.position.y = 'top' else options.position.y = 'bottom'
        
        
        ofa = {x:0,y:0}
        switch options.position.x
          when 'center'
            if options.position.y isnt 'center'
              ofa.x = -size.x/2
          when 'left'
            ofa.x = -(options.offset+size.x)
          when 'right'
            ofa.x = options.offset
        switch options.position.y
          when 'center'
            if options.position.x isnt 'center'
              ofa.y = -size.y/2
          when 'top'
            ofa.y = -(options.offset+size.y)
          when 'bottom'
            ofa.y = options.offset
         options.offset = ofa
        else
          options.relativeTo = document.body
          options.position = {x:'center',y:'center'}
          if typeOf options.offset isnt 'object'
            options.offset = {x:0,y:0}
        @oldPosition.attempt options, @
    removeTransition: ->
      @store 'transition', @getStyle( '-webkit-transition-duration' )
      @setStyle '-webkit-transition-duration', '0'
      
    addTransition: ->
      @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
      @eliminate 'transition'
      
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
        
    grab: (el, where) ->
      @oldGrab.attempt arguments, @
      e = document.id(el)
      if e.fireEvent?
        e.fireEvent 'addedToDom'
      @
      
    inject: (el, where) ->
      @oldInject.attempt arguments, @
      @fireEvent 'addedToDom'
      @
      
    adopt: ->
      @oldAdopt.attempt arguments, @
      elements = Array.flatten(arguments)
      elements.each (el) ->
        e = document.id(el)
        if e.fireEvent?
          document.id(el).fireEvent 'addedToDom'
      @
  }
)()
