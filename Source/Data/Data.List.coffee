###
---

name: Data.List

description: Text data element.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract

provides: Data.List

...
###
Data.List = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  Attributes: {
    class: {
      value: GDotUI.Theme.DataList.class
    }
  }
  create: ->
    @table = new Element 'table', {cellspacing:0, cellpadding:0}
    @base.grab @table
    @cells = []
    @add ''
  update: ->
    @cells.each ((item) ->
      if item.getValue() is ''
        @remove item
      ).bind @
    if @cells.length is 0
      @add ''
    if @cells.getLast().getValue() isnt ''
      @add ''
    @fireEvent 'change', {value:@getValue()}
  add: (value) ->
    cell = new Data.TableCell({value:value})
    cell.addEvent 'editEnd', @update
    cell.addEvent 'next', ->
      cell.input.blur()
    @cells.push cell
    tr = new Element 'tr'
    @table.grab tr
    tr.grab cell
  remove: (cell,remove)->
    cell.removeEvents 'editEnd'
    cell.removeEvents 'next'
    @cells.erase cell
    cell.base.getParent('tr').destroy()
    cell.base.destroy()
    delete cell
  removeAll: ->
    (@cells.filter -> true).each ( (cell) ->
      @remove cell
    ).bind @
  getValue: ->
    map = @cells.map (cell) ->
      cell.getValue()
    map.splice(@cells.length-1,1)
    map
  setValue: (value) ->
    @removeAll()
    self = @
    value.each (item) ->
      self.add item
}
    
