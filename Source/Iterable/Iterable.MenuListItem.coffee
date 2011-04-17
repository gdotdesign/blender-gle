###
---

name: Iterable.MenuListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.MenuListItem

requires: 
  - Iterable.ListItem
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
      value: Lattice.buildClass 'menu-list-item'
    }
  }
  create: ->
    @parent()
    @iconEl = new Core.Icon({class:@get('class')+'-icon'})
    @sc = new Element 'div'
    @sc.setStyle 'float', 'right'
    @title.setStyle 'float', 'left'
    @iconEl.setStyle 'float', 'left'
    @base.grab @iconEl, 'top'
    @base.grab @sc
}
