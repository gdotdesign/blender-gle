###
---

name: Data.Table

description: Text data element.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract

provides: Data.Table

...
###
checkForKey = (key,hash,i) ->
  if not i?
    i = 0
  if not hash[key]?
    key
  else
    if not hash[key+i]?
      key+i
    else
      checkForKey key,hash,i+1
Data.Table = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  options: {
    columns: 1
    class: GDotUI.Theme.Table.class
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @table = new Element 'table', {cellspacing:0, cellpadding:0}
    @base.grab @table
    @rows = []
    @columns = @options.columns
    @header = new Data.TableRow {columns:@columns}
    @header.addEvent 'next', ( ->
      @addCloumn ''
      @header.cells.getLast().editStart()
    ).bind @
    @header.addEvent 'editEnd', ( ->
      @fireEvent 'change', @getData()
      if not @header.cells.getLast().editing
        if @header.cells.getLast().getValue() is ''
          @removeLast()
    ).bind @
    @table.grab @header
    @addRow @columns
    @
  ready: ->
  addCloumn: (name) ->
    @columns++
    @header.add name
    @rows.each (item) ->
      item.add ''
  removeLast: () ->
    @header.removeLast()
    @columns--
    @rows.each (item) ->
      item.removeLast()
  addRow: (columns) ->
    row = new Data.TableRow({columns:columns})
    row.addEvent 'editEnd', @update
    row.addEvent 'next', ((row) ->
      index = @rows.indexOf row
      if index isnt @rows.length-1
        @rows[index+1].cells[0].editStart()
    ).bind @
    @rows.push row
    @table.grab row
  removeRow: (row,erase) ->
    if not erase?
      erase = yes
    row.removeEvents 'editEnd'
    row.removeEvents 'next'
    row.removeAll()
    if erase
      @rows.erase row
    row.base.destroy()
    delete row
  removeAll: (addColumn) ->
    if not addColumn?
      addColumn = yes
    @header.removeAll()
    @rows.each ( (row) ->
      @removeRow row, no
    ).bind @
    @rows.empty()
    @columns = 0
    if addColumn
      @addCloumn()
      @addRow @columns
  update: ->
    length = @rows.length
    longest = 0
    rowsToRemove = []
    @rows.each ( (row, i) ->
      empty = row.empty() # check is the row is empty
      if empty
        rowsToRemove.push row
    ).bind @
    rowsToRemove.each ( (item) ->
      @removeRow item
    ).bind @
    if @rows.length is 0 or not @rows.getLast().empty()
      @addRow @columns
    @fireEvent 'change', @getData()
  getData: ->
    ret = {}
    headers = []
    @header.cells.each (item) ->
      value = item.getValue()        
      ret[checkForKey(value,ret)] =[]
      headers.push ret[value]
    @rows.each ( (row) ->
      if not row.empty()
        row.getValue().each (item,i) ->
          headers[i].push item
    ).bind @
    ret
  getValue: ->
    @getData()
  setValue: (obj) ->
    @removeAll( no )
    rowa = []
    j = 0
    self = @
    new Hash(obj).each (value,key) ->
      self.addCloumn key
      value.each (item,i) ->
        if not rowa[i]?
          rowa[i] = []
        rowa[i][j] = item
      j++
    rowa.each (item,i) ->
      self.addRow self.columns
      self.rows[i].setValue item
    @update()
    @
}
Data.TableRow = new Class {
  Extends: Data.Abstract
  Delegates: {base: ['getChildren']}
  options: {
    columns: 1
    class: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base = new Element 'tr'
    @base.addClass @options.class
    @cells = []
    i = 0
    while i < @options.columns
      @add('')
      i++
  add: (value) ->
    cell = new Data.TableCell({value:value})
    cell.addEvent 'editEnd', ( ->
      @fireEvent 'editEnd'
    ).bind @
    cell.addEvent 'next', ((cell) ->
      index = @cells.indexOf cell
      if index is @cells.length-1
        @fireEvent 'next', @
      else
        @cells[index+1].editStart()
    ).bind @
    @cells.push cell
    @base.grab cell
  empty: ->
    filtered = @cells.filter (item) ->
      if item.getValue() isnt '' then yes else no
    if filtered.length > 0 then no else yes
  removeLast: ->
    @remove @cells.getLast()
  remove: (cell,remove)->
    cell.removeEvents 'editEnd'
    cell.removeEvents 'next'
    @cells.erase cell
    cell.base.destroy()
    delete cell
  removeAll: ->
    (@cells.filter -> true).each ( (cell) ->
      @remove cell
    ).bind @
  getValue: ->
    @cells.map (cell) ->
      cell.getValue()
  setValue: (value) ->
    @cells.each (item,i) ->
      item.setValue value[i]
}
Data.TableCell = new Class {
  Extends: Data.Abstract
  Binds: ['editStart','editEnd']
  options:{
    editable: on
    value: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    delete @base
    @base = new Element 'td', {text: @options.value}
    @value = @options.value
    if @options.editable
      @base.addEvent 'click', @editStart
  editStart: ->
    if not @editing
      @editing = on
      @input = new Element 'input', {type:'text',value:@value}
      @base.set 'html', ''
      @base.grab @input
      @input.addEvent 'change', ( ->
        @setValue @input.get 'value'
      ).bindWithEvent @
      @input.addEvent 'keydown', ( (e) ->
        if e.key is 'enter'
          @input.blur()
        if e.key is 'tab'
          e.stop()
          @fireEvent 'next', @
      ).bind @
      size = @base.getSize()
      @input.setStyles {width: size.x+"px !important",height:size.y+"px !important"}
      @input.focus()
      @input.addEvent 'blur', @editEnd
  editEnd: (e) ->
    if @editing
      @editing = off
    @setValue @input.get 'value'
    if @input?
      @input.removeEvents ['change','keydown']
      @input.destroy()
      delete @input
    @fireEvent 'editEnd'
  setValue: (value) ->
    @value = value
    if not @editing
      @base.set 'text', @value
  getValue: ->
    if not @editing
      @base.get 'text'
    else @input.get 'value'
}
