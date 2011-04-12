###
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Number
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Size

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Binds: ['update']
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'color'
    }
    hue: {
      value: 0
      setter: (value) ->
        @hueData.set 'value', value
        value
      getter: ->
        @hueData.value
    }
    saturation: {
      value: 0
      setter: (value) ->
        @saturationData.set 'value', value
        value
      getter: ->
        @saturationData.value
    }
    lightness: {
      value: 100
      setter: (value) ->
        @lightnessData.set 'value', value
        value
      getter: ->
        @lightnessData.value
    }
    alpha: {
      value: 100
      setter: (value) ->
        @alphaData.set 'value', value
        value
      getter: ->
        @alphaData.value
    }
    type: {
      value: 'hex'
      setter: (value) ->
        @col.children.each (item) ->
          if item.label == value
            @col.set 'active', item
        , @
        value
      getter: ->
        if @col.active?
          @col.active.label
    }
    value: {
      value: new Color('#fff')
      setter: (value) ->
        console.log value.hsb[0], value.hsb[1], value.hsb[2]
        @set 'hue', value.hsb[0]
        @set 'saturation', value.hsb[1]
        @set 'lightness', value.hsb[2]
        @set 'type', value.type
        @set 'alpha', value.alpha
    }
  }
  ready: ->
    @update()
  update: ->
    hue = @get 'hue'
    saturation = @get 'saturation'
    lightness = @get 'lightness'
    type = @get 'type'
    alpha = @get 'alpha'
    if hue? and saturation? and lightness? and type? and alpha?
      ret = $HSB(hue,saturation,lightness)
      ret.setAlpha alpha
      ret.setType type
      @fireEvent 'change', new Hash(ret)
  create: ->
    @addEvent 'sizeChange', =>
      @hueData.set 'size', @size
      @saturationData.set 'size', @size
      @lightnessData.set 'size', @size
      @alphaData.set 'size', @size
      @col.set 'size', @size
    @hueData = new Data.Number {range:[0,360],reset: off, steps: 360, label:'Hue'}
    @saturationData = new Data.Number {range:[0,100],reset: off, steps: 100 , label:'Saturation'}
    @lightnessData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Value'}
    @alphaData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Alpha'}
    
    @col = new Groups.Toggles()
    ['rgb','rgba','hsl','hsla','hex'].each ((item) ->
      @col.addItem new Buttons.Toggle({label:item})
    ).bind @
    
    @hueData.addEvent 'change',  @update
    @saturationData.addEvent 'change',  @update
    @lightnessData.addEvent 'change', @update
    @alphaData.addEvent 'change',  @update
    @col.addEvent 'change',  @update
    
    
    @adoptChildren @hueData, @saturationData, @lightnessData, @alphaData, @col
}
