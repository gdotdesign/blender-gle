###
---

name: Core.Push

description: Toggle button 'push' element.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - Core.Button

provides: Core.Push

...
###
Core.Push = new Class {
  Extends: Core.Button
  Attributes: {
    state: {
      getter: ->
        @base.hasClass 'pushed' 
    }
    label: {
      value: GDotUI.Theme.Push.label
    }
    class: {
      value: GDotUI.Theme.Push.class
    }
  }
  on: ->
    @base.addClass 'pushed'
  off: ->
    @base.removeClass 'pushed'
  create: ->
    @base.addEvent 'click', ( ->
      if @enabled
        @base.toggleClass 'pushed'
    ).bind @  
    @parent()
}
