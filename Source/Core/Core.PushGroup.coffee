###
---

name: Core.PushGroup

description: PushGroup element.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Core.PushGroup
...
###
Core.PushGroup = new Class {
  Extends: Core.Abstract
  Binds: ['change']
  Implements:[
    Interfaces.Enabled
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.PushGroup.class
    }
    active: {
      setter: (value, old) ->
        if not old?
          value.on()
        else
          if old isnt value
            old.off()
          value.on()
        value
    }
  }
  update: ->
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
  change: (button) ->
    if button isnt @active
      @set 'active', button
      @fireEvent 'change', button
  emptyItems: ->
    @children.each (child) ->
      console.log child
      child.removeEvents 'invoked'
    , @
    @empty()
  removeItem: (item) ->
    if @hasChild item
      item.removeEvents 'invoked'
      @removeChild item
    @update()
  addItem: (item) ->
    if not @hasChild item
      item.set 'minSize', 0
      item.addEvent 'invoked', @change
      @addChild item
    @update()
}
