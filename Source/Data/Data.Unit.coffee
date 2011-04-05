###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Number
  - Data.Select 
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Size
  - G.UI/Interfaces.Enabled

provides: Data.Unit

...
###
UnitList = {
  px: "px"
  '%': "%"
  em: "em"
  ex:"ex"
  gd:"gd"
  rem:"rem"
  vw:"vw"
  vh:"vh"
  vm:"vm"
  ch:"ch"
  "in":"in"
  mm:"mm"
  pt:"pt"
  pc:"pc"
  cm:"cm"
  deg:"deg"
  grad:"grad"
  rad:"rad"
  turn:"turn"
  s:"s"
  ms:"ms"
  Hz:"Hz"
  kHz:"kHz"
  }
Data.Unit = new Class {
  Extends:Data.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children 
    Interfaces.Size
  ]
  Binds: ['update']
  Attributes: {
    class: {
      value: GDotUI.Theme.Unit.class
    }
    value: {
      setter: (value) ->
        if typeof value is 'string'
          match = value.match(/(-?\d*)(.*)/)
          value = match[1]
          unit = match[2]
          @sel.set 'value', unit
          @number.set 'value', value
      getter: ->
        String.from @number.value+@sel.value
    }
  }
  update: ->
    @fireEvent 'change', String.from @number.value+@sel.get('value')
  create: ->
    @addEvent 'sizeChange', ( ->
      @number.set 'size', @size-@sel.get('size')
    ).bind @
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select({size: 80})
    Object.each UnitList,((item) ->
      @sel.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    ).bind @
    @sel.set 'value', 'px'

    @number.addEvent 'change', @update
    @sel.addEvent 'change',@update
    @adoptChildren @number, @sel
  ready: ->
    @set 'size', @size
}
    
