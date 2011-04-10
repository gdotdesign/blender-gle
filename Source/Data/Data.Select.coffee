###
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - Core.Picker
  - G.UI/Data.Abstract
  - Dialog.Prompt
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size
  - Iterable.List

provides: Data.Select

...
###
Data.Select = new Class {
  Extends: Data.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
    Interfaces.Size
    Interfaces.Children]
  Attributes: {
    class: {
      value: 'blender-select'
    }
    default: {
      value: ''
      setter: (value, old) ->
        if @text.get('text') is (old or '')
          @text.set 'text', value
        value
    }
    selected: {
      getter: ->
        @list.get 'selected'
    }
    editable: {
      value: yes
      setter: (value) ->
        if value
          @adoptChildren  @removeIcon, @addIcon
        else
          document.id(@removeIcon).dispose()
          document.id(@addIcon).dispose()
        value
    }
    value: {
      setter: (value) ->
        @list.set 'selected', @list.getItemFromLabel(value)
      getter: ->
        li = @list.get('selected')
        if li?
          li.label
    }
    textClass: {
      value: GDotUI.Theme.Select.textClass
      setter: (value, old) ->
        @text.removeClass old
        @text.addClass value
        value 
    }
    removeClass: {
      value: GDotUI.Theme.Select.removeClass
      setter: (value, old) ->
        @removeIcon.base.removeClass old
        @removeIcon.base.addClass value
        value 
    }
    addClass: {
      value: GDotUI.Theme.Select.addClass
      setter: (value, old) ->
        @addIcon.base.removeClass old
        @addIcon.base.addClass value
        value 
    }
    listClass: {
      value: 'blender-list'
      setter: (value) ->
        @list.set 'class', value
    }
  }
  ready: ->
    @set 'size', @size
  create: ->
    @addEvent 'sizeChange', ( ->
      @list.base.setStyle 'width', if @size < @minSize then @minSize else @size
    ).bind @
    
    @base.setStyle 'position', 'relative'
    @text = new Element 'div'
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
    @text.addEvent 'mousewheel', ((e)->
      e.stop()
      index = @list.items.indexOf(@list.selected)+e.wheel
      if index < 0 then index = @list.items.length-1
      if index is @list.items.length then index = 0
      @list.set 'selected', @list.items[index]
    ).bind @
    @addIcon = new Core.Icon()
    @addIcon.base.set 'text', '+'
    @removeIcon = new Core.Icon()
    @removeIcon.base.set 'text', '-'
    $$(@addIcon.base,@removeIcon.base).setStyles {
      'z-index': '1'
      'position': 'relative'
    }
    @removeIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @removeItem @list.get('selected')
        @text.set 'text', @default or ''
    ).bind @
    @addIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @prompt.show()
    ).bind @
    
    @picker = new Core.Picker({offset:0,position:{x:'center',y:'auto'}})
    @picker.attach @base, false
    @base.addEvent 'click', ((e) ->
      if @enabled
        @picker.show e
    ).bind @
    @list = new Iterable.List()
    @picker.set 'content', @list
    @base.adopt @text
    
    @prompt = new Dialog.Prompt();
    @prompt.set 'label', 'Add item:'
    @prompt.attach @base, false
    @prompt.addEvent 'invoked', ((value) ->
      if value
        item = new Iterable.ListItem {label:value,removeable:false,draggable:false}
        @addItem item
        @list.set 'selected', item
      @prompt.hide null, yes
    ).bind @
    
    @list.addEvent 'selectedChange', ( ->
      item = @list.selected
      if item?
        @text.set 'text', item.label
        @fireEvent 'change', item.label
      else
        @text.set 'text', ''
      @picker.hide null, yes
    ).bind @
    @update()
    
  addItem: (item) ->
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}
