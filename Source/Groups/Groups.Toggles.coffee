###
---

name: Groups.Toggles

description: PushGroup element.

license: MIT-style license.

requires: 
  - Groups.Abstract
  - Interfaces.Enabled
  - Interfaces.Size

provides: Groups.Toggles
...
###
Groups.Toggles = new Class {
  Extends: Groups.Abstract
  Binds: ['change']
  Implements:[
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'toggle-group'
    }
    active: {
      setter: (value, old) ->
        if not old?
          value.set 'state', true
        else
          if old isnt value
            old.set 'state', false
          value.set 'state', true
        value
    }
  }
  update: ->
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
  change: (button,value) ->
    if button isnt @active
      if button.state
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
      @parent item
    @update()
  addItem: (item) ->
    if not @hasChild item
      item.set 'minSize', 0
      item.addEvent 'invoked', @change
      @parent item
    @update()
}
