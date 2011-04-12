###
---

name: Core.Scrollbar

description: Scrollbar element.

license: MIT-style license.

requires: 
  - Core.Slider
  
provides: Core.Scrollbar

...
###
Core.Scrollbar = new Class {
  Extends: Core.Slider
  Attributes: {
    mode: {
      setter: (value, old, self) ->
        self::parent.call @, value, old
        switch value
          when 'horizontal'
            @smodif = 'left'
            @drag.options.modifiers = {
              x:'left'
              y:''
            }
          when 'vertical'
            @smodif = 'top'
            @drag.options.modifiers = {
              x:''
              y:'top'
            }
            @drag.options.invert = false
        value
    }
    value: {
      getter: ->
        if @reset
          @value
        else
          width = @size-@progressSize
          Number.from(@progress.getStyle(@smodif)) / width * @steps
      setter: (value) ->
        value = Number.from value
        width = @size-@progressSize
        if !@reset
          percent = Math.round((value/@steps)*100)
          if value < 0
            @progress.setStyle @smodif, 0
            value = 0
          else if value > @steps
            @progress.setStyle @smodif, width
            value = @steps
          else if not(value < 0) and not(value > @steps)
            @progress.setStyle @smodif, (percent/100)*width
        value
    }
    size: {
      setter: (value, old) ->
        if !value?
          value = old
        else
          value = Number.from value
        if @minSize > value
          value = @minSize
        @base.setStyle @modifier, value
        @progress.setStyle @modifier, (value*0.7)
        @progressSize = (value*0.7)
        value
    }
  }
  create: ->
    @parent()
  onDrag: (el,e) ->
    if @enabled
      left = Number.from(@progress.getStyle(@smodif))
      width = @size-@progressSize
      if left < @size-@progressSize
        @value = left/width*@steps
      else  
        el.setStyle @smodif, @size-@progressSize
        @value = @steps
      if left < 0
        el.setStyle @smodif, 0
        @value = 0
      @fireEvent 'step', Math.round(@value)
    else
      @set 'value', @value
    
}
