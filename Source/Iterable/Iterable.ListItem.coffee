###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: 
  - G.UI/GDotUI
  - G.UI/Interfaces.Draggable
...
###
Iterable.ListItem = new Class {
  Extends:Core.Abstract
  Implements: [Interfaces.Draggable
               Interfaces.Enabled 
               Options]
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @title.set 'text', value
        value
    }
    class: {
      value: 'blender-list-item'
    }
  }
  options:{
    classes:{
      title: GDotUI.Theme.ListItem.title
      subtitle: GDotUI.Theme.ListItem.subTitle
    }
    title:''
    subtitle:''
    draggable: off
    dragreset: on
    ghost: on
    removeClasses: '.'+GDotUI.Theme.Icon.class
    invokeEvent: 'click'
    selectEvent: 'click'
    removeable: on
    sortable: off
    dropppables: ''
  }
  initialize: (options) ->
    @setOptions options
    @parent options
  create: ->
    @base.setStyle 'position','relative'
    #@remove = new Core.Icon {image: @options.icons.remove}
    #@handles = new Core.Icon {image: @options.icons.handle}
    #@handles.base.addClass  @options.classes.handle
    
    #$$(@remove.base,@handles.base).setStyle 'position','absolute'
    @title = new Element 'div'
    @subtitle = new Element 'div'
    @base.adopt @title,@subtitle
    #if @options.removeable
    #  @base.grab @remove
    #if @options.sortable
    #  @base.grab @handle
    @base.addEvent @options.selectEvent, ( (e)->
      @fireEvent 'select', [@,e]
      ).bindWithEvent @
    @base.addEvent @options.invokeEvent, ( ->
      if @enabled and not @options.draggable and not @editing
        @fireEvent 'invoked', @
    ).bindWithEvent @
    @addEvent 'dropped', ( (el,drop,e) ->
      @fireEvent 'invoked', [@ ,e, drop]
    ).bindWithEvent @
    @base.addEvent 'dblclick', ( ->
      if @enabled
        if @editing
          @fireEvent 'edit', @
    ).bindWithEvent @
    #@remove.addEvent 'invoked', ( ->
    #  @fireEvent 'delete', @
    #).bindWithEvent @
    @
  toggleEdit: ->
    if @editing
      if @options.draggable
        @drag.attach()
      @remove.base.setStyle 'right', -@remove.base.getSize().x
      @handles.base.setStyle 'left', -@handles.base.getSize().x
      @base.setStyle 'padding-left' , @base.retrieve( 'padding-left:old')
      @base.setStyle 'padding-right', @base.retrieve( 'padding-right:old')
      @editing = off
    else
      if @options.draggable
        @drag.detach()
      @remove.base.setStyle 'right', @options.offset
      @handles.base.setStyle 'left', @options.offset
      @base.store 'padding-left:old', @base.getStyle('padding-left')
      @base.store 'padding-right:old', @base.getStyle('padding-left')
      @base.setStyle 'padding-left', Number(@base.getStyle('padding-left').slice(0,-2))+@handles.base.getSize().x
      @base.setStyle 'padding-right', Number(@base.getStyle('padding-right').slice(0,-2))+@remove.base.getSize().x
      @editing = on
  ready: ->
    if not @editing
      #handSize = @handles.base.getSize()
      #remSize = @remove.base.getSize()
      baseSize = @base.getSize()
      #@remove.base.setStyles {
      #  "right":-remSize.x
      #  "top":(baseSize.y-remSize.y)/2
      #  }
      #@handles.base.setStyles {
      #  "left":-handSize.x,
      #  "top":(baseSize.y-handSize.y)/2
      #  }
      @parent()
      if @options.draggable
        @drag.addEvent 'beforeStart',( ->
          #recalculate drops
          @fireEvent 'select', @
          ).bindWithEvent @
}
