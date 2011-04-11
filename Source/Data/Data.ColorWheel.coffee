###
---

name: Data.ColorWheel

description: ColorWheel data element. ( color picker )

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Color
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Data.ColorWheel

...
###
Data.ColorWheel = new Class {
  Extends: Data.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'color'
    }
    value: {
      setter: (value) ->
        @colorData.set 'value', value
    }
    wrapperClass: {
      value: 'wrapper'
      setter: (value, old) ->
        @wrapper.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
    knobClass: {
      value: 'xyknob'
      setter: (value, old) ->
        @knob.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
  }
   
  create: ->
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element 'div'
   
    @knob = new Element 'div'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color()
    @colorData.addEvent 'change', ( (e)->
      @fireEvent 'change', e
    ).bind @
    
    @base.adopt @wrapper

    @colorData.lightnessData.addEvent 'change',( (step) ->
      @hslacone.setStyle 'opacity',step/100
    ).bind @
    @colorData.hueData.addEvent 'change', ((value) ->
      @positionKnob value, @colorData.get('saturation')
    ).bind @  
    @colorData.saturationData.addEvent 'change', ((value) ->
      @positionKnob @colorData.get('hue'), value
    ).bind @
    
    @background.setStyles {
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 1
    }
    
    @xy = new Drag.Move @knob
    @xy.addEvent 'beforeStart',((el,e) ->
        @lastPosition = el.getPosition(@wrapper)
      ).bind @
    @xy.addEvent 'drag', ((el,e) ->
      if @enabled
        position = el.getPosition(@wrapper)
        
        x = @center.x-position.x-@knobSize.x/2
        y = @center.y-position.y-@knobSize.y/2
        
        @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
        @angle = Math.atan2(y,x)
        
        if @radius > @halfWidth
          el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@knobSize.y/2+@center.y
          el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@knobSize.x/2+@center.x
          @saturation = 100
        else
          sat =  Math.round @radius 
          @saturation = Math.round((sat/@halfWidth)*100)
        
        an = Math.round(@angle*(180/Math.PI))
        @hue = if an < 0 then 180-Math.abs(an) else 180+an
        @colorData.set 'hue', @hue
        @colorData.set 'saturation', @saturation
      else
        el.setPosition @lastPosition
    ).bind @
    
    @wrapper.adopt @background, @hslacone, @knob
    @addChild @colorData
  drawHSLACone: (width) ->
    ctx = @background.getContext '2d'
    ctx.fillStyle = "#000";
    ctx.beginPath();
    ctx.arc(width/2, width/2, width/2, 0, Math.PI*2, true); 
    ctx.closePath();
    ctx.fill();
    ctx = @hslacone.getContext '2d'
    ctx.translate width/2, width/2
    w2 = -width/2
    ang = width / 50
    angle = (1/ang)*Math.PI/180
    i = 0
    for i in [0..(360)*(ang)-1]
      c = $HSB(360+(i/ang),100,100)
      c1 = $HSB(360+(i/ang),0,100)
      grad = ctx.createLinearGradient(0,0,width/2,0)
      grad.addColorStop(0, c1.hex)
      grad.addColorStop(1, c.hex)
      ctx.strokeStyle = grad
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(width/2,0)
      ctx.stroke()
      ctx.rotate(angle)
  
  update: ->  
    @hslacone.set 'width', @size
    @hslacone.set 'height', @size
    @background.set 'width', @size
    @background.set 'height', @size
    @wrapper.setStyle 'height', @size
    if @size > 0
      @drawHSLACone @size
    @colorData.set 'size', @size
    
    @knobSize = @knob.getSize()
    @halfWidth = @size/2
    @center = {x: @halfWidth, y:@halfWidth}
    @positionKnob @colorData.get('hue'), @colorData.get('saturation')
  positionKnob: (hue,saturation) ->
    @radius = saturation/100*@halfWidth
    @angle = -((180-hue)*(Math.PI/180))
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@knobSize.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@knobSize.x/2+@center.x
  ready: ->
    @update()
    
}
