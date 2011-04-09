###
---

name: Core.IconGroup

description: Icon group with 5 types of layout.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled

provides: Core.IconGroup

todo: Circular center position and size
...
###
Core.IconGroup = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Binds: ['delegate']
  Attributes: {
    mode: {
      value: "horizontal"
      validator: (value) ->
        if ['horizontal','vertical','circular','grid','linear'].indexOf(value) > -1 then true else false
    }
    spacing: {
      value: {x: 0,y: 0}
      validator: (value) ->
        if typeOf(value) is 'object'
          if value.x? and value.y? then yes else no
        else no
    }
    startAngle: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a >= 0 and a <= 360
        else no
    }
    radius: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        (a = Number.from(value))?
    }
    degree: {
      value: 360
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a >= 0 and a <= 360
        else no
    }
    rows: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    columns: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    class: {
      value: 'blender-icon-group'
    }
  }
  create: ->
    @base.setStyle 'position', 'relative'
  delegate: ->
    @fireEvent 'invoked', arguments
  addIcon: (icon) ->
    if not @hasChild icon
      icon.addEvent 'invoked', @delegate
      @addChild icon
      @update()
  removeIcon: (icon) ->
    if @hasChild icon
      icon.removeEvent 'invoked', @delegate
      @removeChild icon
      @update()
  ready: ->
    @update()
  update: ->
    if @children.length > 0 and @mode? 
      x = 0
      y = 0
      @size = {x:0, y:0}
      spacing = @spacing
      switch @mode
        when 'grid'
          if @rows? and @columns?
            if @rows < @columns
              rows = null
              columns = @columns
            else
              columns = null
              rows = @rows
          icpos = @children.map (item,i) =>
            if rows?
              if i % rows == 0
                y = 0
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
              else
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
            if columns?
              if i % columns == 0
                x = 0
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
              else
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
        when 'linear'
          icpos = @children.map (item,i) =>
            x = if i==0 then x+x else x+spacing.x+item.base.getSize().x
            y = if i==0 then y+y else y+spacing.y+item.base.getSize().y
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
        when 'horizontal'
          icpos = @children.map (item,i) =>
            x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
            y = if i==0 then y else y
            @size.x = x+item.base.getSize().x
            @size.y = item.base.getSize().y
            {x:x, y:y}
        when 'vertical'
          icpos = @children.map (item,i) =>
            x = if i==0 then x else x
            y = if i==0 then y+y else y+item.base.getSize().y+spacing.y
            @size.x = item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x,y:y}
        when 'circular'
          n = @children.length
          radius = @radius
          startAngle = @startAngle
          ker = 2*@radius*Math.PI
          fok = @degree/n
          icpos = @children.map (item,i) ->
            if i==0
              foks = startAngle * (Math.PI/180)
              x = Math.round(radius * Math.sin(foks))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(foks))+radius/2+item.base.getSize().y
            else
              x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().y
            {x:x, y:y}
      @base.setStyles {
        width: @size.x
        height: @size.y
      }
      @children.each (item,i) ->
        item.base.setStyle 'top', icpos[i].y
        item.base.setStyle 'left', icpos[i].x
        item.base.setStyle 'position', 'absolute'
}
