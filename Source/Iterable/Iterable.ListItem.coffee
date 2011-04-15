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
      setter: (value,old,self)->
        self::parent.call @, value, old
        @title.replaceClass "#{value}-title", "#{old}-title"
        value
    }
  }
  create: ->
    @title = new Element 'div'
    @base.grab @title
    @base.addEvent 'click', (e) =>
      @fireEvent 'select', [@,e]
    @base.addEvent 'click', =>
      @fireEvent 'invoked', @
}
