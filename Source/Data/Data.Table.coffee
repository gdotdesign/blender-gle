###
---

name: Data.Table

description: Text data element.

requires: 
  - Data.Abstract

provides: Data.Table

...
###
Data.Table = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  Attributes: {
    class: {
      value: Lattice.buildClass 'table'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @hremove.set 'class', value+"-remove"
        @hadd.set 'class', value+"-add"
        @vremove.set 'class', value+"-remove"
        @vadd.set 'class', value+"-add"
        value
    }
    value: {
      setter: (value) ->
        @base.empty()
        value.each (it) -> 
          tr = new Element('tr')
          @base.grab tr
          it.each (v) ->
            tr.grab new Element('td',{text:v})
          , @
        , @
        @fireEvent 'change', @get 'value'
        value
      getter: ->
        ret = []
        for tr in @base.children
          tra = []
          for td in tr.children
            tra.push td.get 'text'
          ret.push tra
        ret
    }
  }
  create: ->
    @loc = {h:0,v:0}
    delete @base
    @base = new Element 'table'
    @base.grab new Element('tr').grab(new Element 'td')
    @columns = 5
    @rows = 1
    @input = new Element 'input'
    @setupIcons()
    @setupEvents()
    
  setupEvents: ->
    @hadd.addEvent 'invoked', @addColumn.bind @
    @hremove.addEvent 'invoked', @removeColumn.bind @
    @vadd.addEvent 'invoked', @addRow.bind @
    @vremove.addEvent 'invoked', @removeRow.bind @
    
    @icg1.base.addEvent 'mouseenter', @suspendIcons.bind @
    @icg1.base.addEvent 'mouseleave', @hideIcons.bind @
    @icg2.base.addEvent 'mouseenter', @suspendIcons.bind @
    @icg2.base.addEvent 'mouseleave', @hideIcons.bind @ 
    
    @base.addEvent 'mouseleave', (e) => 
      @id1 = @icg1.hide.delay(400,@icg1)
      @id2 = @icg2.hide.delay(400,@icg2)
    @base.addEvent 'mouseenter', (e) =>
      @suspendIcons()
      @icg1.show()
      @icg2.show()
    @base.addEvent 'mouseenter:relay(td)', (e) => 
      @positionIcons e.target
    @input.addEvent 'blur', =>
      @input.dispose()
      @editTarget.set 'text', @input.get 'value'
      @fireEvent 'change', @get 'value'
    @base.addEvent 'click:relay(td)', (e) =>
      if @input.isVisible()
        @input.dispose()
        @editTarget.set 'text', @input.get 'value'
      @input.set 'value', e.target.get 'text'
      size = e.target.getSize()
      @input.setStyles {
        width: size.x
        height: size.y
      }
      @editTarget = e.target
      e.target.set 'text', ''
      e.target.grab @input
      @input.focus()
      
  positionIcons: (target) ->
    pos = target.getPosition()
    pos1 = @base.getPosition()
    size = @icg1.base.getSize()
    size2 = @base.getSize()
    @icg1.base.setStyle 'left', pos.x
    @icg1.base.setStyle 'top', pos1.y-size.y
    @icg2.base.setStyle 'top', pos.y
    @icg2.base.setStyle 'left', pos1.x+size2.x
    @loc = @getLocation target
    @target = target
    @vremove.set 'enabled', @base.children.length > 1
    @hremove.set 'enabled', @base.children[0].children.length > 1
    
  setupIcons: ->
    @icg1 = new Groups.Icons()
    @icg2 = new Groups.Icons()
    
    @hadd = new Core.Icon()
    @hremove = new Core.Icon()
    @vadd = new Core.Icon()
    @vremove = new Core.Icon()
    
    @hadd.base.set 'text', '+'
    @hremove.base.set 'text', '-'
    @vadd.base.set 'text', '+'
    @vremove.base.set 'text', '-'
    
    @icg1.addItem @hadd
    @icg1.addItem @hremove
    @icg2.addItem @vadd
    @icg2.addItem @vremove
    
    @icg1.base.setStyle 'position', 'absolute'
    @icg2.base.setStyle 'position', 'absolute'
    
    document.body.adopt @icg1, @icg2
    @hideIcons()
    
  suspendIcons: ->
    if @id1?
      clearTimeout @id1
      @id1 = null
    if @id2?
      clearTimeout @id2
      @id2 = null
  hideIcons: ->
    @icg1.hide()
    @icg2.hide()
    
  getLocation: (td) ->
    ret = {h:0,v:0}
    tr = td.getParent('tr')
    children = tr.getChildren()
    for i in [0..children.length]
      if td is children[i]
        ret.h = i
    children = @base.getChildren()
    for i in [0..children.length]
      if tr is children[i]
        ret.v = i
    ret
      
  testHorizontal: (where) ->
    if (w = Number.from(where))?
      if w < @base.children[0].children.length and w > 0
        @loc.h = w-1    

  testVertical: (where) ->
    if (w = Number.from(where))?
      if w < @base.children.length and w > 0
        @loc.v = w-1

  addRow: (where) ->
    @testVertical where
    tr = new Element 'tr'
    baseChildren = @base.children
    trchildren = baseChildren[0].children
    if baseChildren.length > 0
      baseChildren[@loc.v].grab tr, 'before'
    else
      @base.grab tr
    for i in [1..trchildren.length]
      tr.grab new Element 'td'
    @positionIcons @base.children[@loc.v].children[@loc.h]
    @fireEvent 'change', @get 'value'
    
  addColumn: (where) ->
    @testHorizontal where
    for tr in @base.children
      tr.children[@loc.h].grab new Element('td'), 'before'
    @positionIcons @base.children[@loc.v].children[@loc.h]
    @fireEvent 'change', @get 'value'
    
  removeRow: (where) ->
    @testVertical where
    if @base.children.length isnt 1
      @base.children[@loc.v].destroy()
      if @base.children[@loc.v]?
        @positionIcons @base.children[@loc.v].children[@loc.h]
      else
        @positionIcons @base.children[@loc.v-1].children[@loc.h]
    @fireEvent 'change', @get 'value'
  
  removeColumn: (where) ->
    @testHorizontal where
    if @base.children[0].children.length isnt 1
      for tr in @base.children
        tr.children[@loc.h].destroy()
      if @base.children[@loc.v].children[@loc.h]?
        @positionIcons @base.children[@loc.v].children[@loc.h]
      else
        @positionIcons @base.children[@loc.v].children[@loc.h-1]
    @fireEvent 'change', @get 'value'
      
}
