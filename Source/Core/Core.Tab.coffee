###
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract

provides: Core.Tab

...
###
Core.Tab = new Class {
  Extends: Core.Abstract
  Attributes: {
    class: {
      value: GDotUI.Theme.Tab.class
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'text', value
        value
    }
    activeClass: {
      value: GDotUI.Theme.Global.active
    }
  }
  create: ->
    @base.addEvent 'click', ( ->
      @fireEvent 'activate', @
    ).bind @
    @base.adopt @label
  activate: (event) ->
    if event
      @fireEvent 'activated', @
    @base.addClass @activeClass 
  deactivate: (event) ->
    if event
      @fireEvent 'deactivated', @
    @base.removeClass @activeClass
}
