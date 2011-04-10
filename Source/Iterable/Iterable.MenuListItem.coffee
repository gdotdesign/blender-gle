###
---

name: Iterable.MenuListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.MenuListItem

requires: 
  - G.UI/GDotUI
  - G.UI/Interfaces.Draggable
...
###
Iterable.MenuListItem = new Class {
  Extends: Iterable.ListItem
  Attributes: {
    icon: {
      setter: (value) ->
        @iconEl.set 'image', value
    }
    shortcut: {
      setter: (value) ->
        @sc.set 'text', value.toUpperCase()
        value
    }
    class: {
      value: 'blender-menu-list-item'
    }
  }
  create: ->
    @parent()
    @iconEl = new Core.Icon({class:'blender-menu-list-item-icon'})
    @sc = new Element 'div.shortcut'
    @sc.setStyle 'float', 'right'
    @title.setStyle 'float', 'left'
    @iconEl.base.setStyle 'float', 'left'
    @base.grab @iconEl, 'top'
    @base.grab @sc
}
