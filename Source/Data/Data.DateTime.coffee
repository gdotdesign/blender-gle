###
---

name: Data.DateTime

description:  Date & Time picker elements with Core.Slot-s

license: MIT-style license.

requires: 
  - Core.Slot
  - Data.Abstract
  - Interfaces.Children
  - Interfaces.Enabled
  - Iterable.ListItem

provides: 
  - Data.DateTime
  - Data.Date
  - Data.Time

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'date-time'
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
    @yearFrom = 1950
    if @get('date')
      @days = new Core.Slot()
      @month = new Core.Slot()
      @years = new Core.Slot()
    if @get('time')
      @hours = new Core.Slot()
      @minutes = new Core.Slot()
    @populate()
    if @get('time')
      @hours.addEvent 'change', (item) =>
        @value.set 'hours', item.value
        @update()
      @minutes.addEvent 'change', (item) =>
        @value.set 'minutes', item.value
        @update()
    if @get('date')
      @years.addEvent 'change', (item) =>
        @value.set 'year', item.value
        @update()
      @month.addEvent 'change', (item) =>
        @value.set 'month', item.value
        @update()
      @days.addEvent 'change', (item) =>
        @value.set 'date', item.value
        @update()
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
        item = new Iterable.ListItem {label:(if i<10 then '0'+i else i),removeable:false}
        item.value = i+1
        @days.addItem item
        i++
      i = 0
      while i < 12
        item = new Iterable.ListItem {label:(if i<10 then '0'+i else i),removeable:false}
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
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
    @updateSlots()
  ready: ->
    if @get('date')
      @adoptChildren @years, @month, @days
    if @get('time')
      @adoptChildren @hours, @minutes
    @update()
  updateSlots: ->
    if @get('date') and @value
      cdays = @value.get 'lastdayofmonth'
      listlength = @days.list.children.length
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
          @days.list.removeItem @days.list.children[i-1]
          i--
      @days.list.set 'selected', @days.list.children[@value.get('date')-1]
      @month.list.set 'selected', @month.list.children[@value.get('month')]
      @years.list.set 'selected', @years.list.getItemFromLabel(@value.get('year'))
    if @get('time') and @value
      @hours.list.set 'selected', @hours.list.children[@value.get('hours')]
      @minutes.list.set 'selected', @minutes.list.children[@value.get('minutes')]
}
Data.Time = new Class {
  Extends:Data.DateTime
  Attributes: {
    class: {
      value: Lattice.buildClass 'time'
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
      value: Lattice.buildClass 'date'
    }
    time: {
      value: no
    }
  }
}
