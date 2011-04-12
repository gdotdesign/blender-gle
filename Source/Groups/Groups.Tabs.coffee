###
---

name: Groups.Tabs

description: Tab navigation element.

license: MIT-style license.

requires: 
  - Groups.Abstract

provides: Groups.Tabs

...
###
Groups.Tabs = new Class {
  Extends: Groups.Abstract
  Binds:['change']
  Attributes: {
    class: {
      value:  'blender-group-tab'
    }
    active: {
      setter: (value, old) ->
        if not old?
          value.activate(false)
        else
          if old isnt value
            old.deactivate(false)
          value.activate(false)
        value
    }
  }
  add: (tab) ->
    if not @hasChild tab
      @addChild tab
      tab.addEvent 'activate', @change
  remove: (tab) ->
    if @hasChild tab
      @removeChild tab
  change: (tab) ->
    if tab isnt @active
      @set 'active', tab
      @fireEvent 'change', tab
  getByLabel: (label) ->
    (@children.filter (item, i) ->
      if item.label is label
        true
      else
        false)[0]
}
