###
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires: 
  - Core.Abstract

provides: Core.Tab

...
###
Core.Tab = new Class {
  Extends: Core.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'tab'
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'text', value
        value
    }
    activeClass: {
      value: 'active'
    }
  }
  create: ->
    @base.addEvent 'click', =>
      @fireEvent 'activate', @
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
