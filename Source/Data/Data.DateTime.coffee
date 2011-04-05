###
---

name: Data.DateTime

description:  Date & Time picker elements with Core.Slot-s

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - Core.Slot
  - G.UI/Data.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Iterable.ListItem

provides: 
  - Data.DateTime
  - Data.Date
  - Data.Time

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.DateTime.class
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
    }
    time: {
      readonly: yes
      value: yes
    }
    date: {
      readonly: yes
      value: yes
    }
  }
  create: ->
    @yearFrom = GDotUI.Theme.Date.yearFrom
    if @get('date')
      @days = new Core.Slot()
      @month = new Core.Slot()
      @years = new Core.Slot()
    if @get('time')
      @hours = new Core.Slot()
      @minutes = new Core.Slot()
    @populate()
    if @get('time')
      @hours.addEvent 'change', ( (item) ->
        @value.set 'hours', item.value
        @update()
      ).bind @
      @minutes.addEvent 'change', ( (item) ->
        @value.set 'minutes', item.value
        @update()
      ).bind @
    if @get('date')
      @years.addEvent 'change', ( (item) ->
        @value.set 'year', item.value
        @update()
      ).bind @
      @month.addEvent 'change', ( (item) ->
        @value.set 'month', item.value
        @update()
      ).bind @
      @days.addEvent 'change', ( (item) ->
        @value.set 'date', item.value
        @update()
      ).bind @
    @
  populate: ->
    if @get('time')
      i = 0
      while i < 24
        item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
        item.value = i
        @hours.addItem item
        i++
      i = 0
      while i < 60
        item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
        item.value = i
        @minutes.addItem item
        i++
    if @get('date')
      i = 0
      while i < 30
        item = new Iterable.ListItem {label:i+1,removeable:false}
        item.value = i+1
        @days.addItem item
        i++
      i = 0
      while i < 12
        item = new Iterable.ListItem {label:i+1,removeable:false}
        item.value = i
        @month.addItem item
        i++
      i = @yearFrom
      while i <= new Date().get 'year'
        item = new Iterable.ListItem {label:i,removeable:false}
        item.value = i
        @years.addItem item
        i++
  update: ->
    @fireEvent 'change', @value
  ready: ->
    if @get('date')
      @adoptChildren @years, @month, @days
    if @get('time')
      @adoptChildren @hours, @minutes
  updateSlots: ->
    if @get('date')
      cdays = @value.get 'lastdayofmonth'
      listlength = @days.list.items.length
      if cdays > listlength
        i = listlength+1
        while i <= cdays
          item=new Iterable.ListItem {label:i}
          item.value = i
          @days.addItem item
          i++
      else if cdays < listlength
        i = listlength
        while i > cdays
          @days.list.removeItem @days.list.items[i-1]
          i--
      @days.list.set 'selected', @days.list.items[@value.get('date')-1]
      @month.list.set 'selected', @month.list.items[@value.get('month')]
      @years.list.set 'selected', @years.list.getItemFromTitle(@value.get('year'))
    if @get('time')
      @hours.list.set 'selected', @hours.list.items[@value.get('hours')]
      @minutes.list.set 'selected', @minutes.list.items[@value.get('minutes')]
}
Data.Time = new Class {
  Extends:Data.DateTime
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.Time.class
    }
    date: {
      value: no
    }
  }
}
Data.Date = new Class {
  Extends:Data.DateTime
  Attributes: {
    class: {
      value: GDotUI.Theme.Date.class
    }
    time: {
      value: no
    }
  }
}
