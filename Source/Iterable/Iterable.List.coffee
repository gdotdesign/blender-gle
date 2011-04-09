###
---

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

requires: 
  - G.UI/GDotUI
...
###
Iterable.List = new Class {
  Extends:Core.Abstract
  options:{
    class: 'blender-list'
    selected: 'blender-list-selected'
    search: off
  }
  Attributes: {
    selected: {
      getter: ->
        @items.filter(((item) ->
          if item.base.hasClass @options.selected then true else false
        ).bind(@))[0]
      setter: (value, old) ->
        if old
          old.base.removeClass @options.selected
        if value?
          value.base.addClass @options.selected
        value
        
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @sortable = new Sortables null
    @editing = off
    if @options.search
      @sinput = new Element 'input', {class:'search'}
      @base.grab @sinput
      @sinput.addEvent 'keyup', ( ->
          @search()
      ).bindWithEvent @
    @items = []
  ready: ->
  search: ->
    svalue = @sinput.get 'value'
    @items.each ( (item) ->
      if item.title.get('text').test(/#{svalue}/ig) or item.subtitle.get('text').test(/#{svalue}/ig)
        item.base.setStyle 'display', 'block'
      else
        item.base.setStyle 'display', 'none'
    ).bind @
  removeItem: (li) ->
    li.removeEvents 'invoked', 'edit', 'delete'
    @items.erase li
    li.base.destroy()
  removeAll: ->
    if @options.search
      @sinput.set 'value', ''
    @selected = null
    @base.empty()
    @items.empty()
  toggleEdit: ->
    bases = @items.map (item) ->
      return item.base
    if @editing
      @sortable.removeItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = off
    else
      @sortable.addItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = on
  getItemFromTitle: (title) ->
    filtered = @items.filter (item) ->
      if String.from(item.title.get('text')).toLowerCase() is String(title).toLowerCase()
        yes
      else no
    filtered[0]
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'select', ( (item,e)->
      @set 'selected', item 
      ).bindWithEvent @
    li.addEvent 'invoked', ( (item) ->
      @fireEvent 'invoked', arguments
      ).bindWithEvent @
    li.addEvent 'edit', ( -> 
      @fireEvent 'edit', arguments
      ).bindWithEvent @
    li.addEvent 'delete', ( ->
      @fireEvent 'delete', arguments
      ).bindWithEvent @
}
