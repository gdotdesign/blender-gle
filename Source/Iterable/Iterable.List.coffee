###
---

name: Iterable.List

description: List element.

license: MIT-style license.

requires:
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Size

provides: Iterable.List

...
###
Iterable.List = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'list'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @children.each (item) =>
          if item.base.hasClass @selectedClass
            item.base.removeClass @selectedClass
        @set 'selectedClass', "#{value}-selected"
        @set 'selected', @selected
        value
    }
    selectedClass: {
      value: Lattice.buildClass 'list-selected'
    }
    selected: {
      getter: ->
        @children.filter(((item) ->
          if item.base.hasClass @selectedClass then true else false
        ).bind(@))[0]
      setter: (value, old) ->
        if old
          old.base.removeClass @selectedClass
        if value?
          value.base.addClass @selectedClass
        value
        
    }
  }
  getItemFromLabel: (label) ->
    filtered = @children.filter (item) ->
      if String.from(item.label).toLowerCase() is String(label).toLowerCase()
        yes
      else no
    filtered[0]
  addItem: (li) -> 
    @addChild li
    li.addEvent 'select', (item,e) =>
      @set 'selected', item 
    li.addEvent 'invoked', (item) =>
      @fireEvent 'invoked', arguments
  removeItem: (li) ->
    if @hasChild li
      li.removeEvents 'select'
      li.removeEvents 'invoked'
      @removeChild li
}
