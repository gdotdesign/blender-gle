###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: 
  - Core.Abstract
...
###
Iterable.ListItem = new Class {
  Extends: Core.Abstract
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @title.set 'text', value
        value
    }
    class: {
      value: Lattice.buildClass 'list-item'
    }
  }
  create: ->
    @title = new Element('div').addClass(@get('class')+'-title')
    @base.grab @title
    @base.addEvent 'click', (e) =>
      @fireEvent 'select', [@,e]
    @base.addEvent 'click', =>
      @fireEvent 'invoked', @
}
