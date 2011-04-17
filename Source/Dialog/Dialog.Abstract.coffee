###
---

name: Dialog.Abstract

description: Dialog abstract base class.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Buttons.Abstract

provides: Dialog.Abstract

...
###
Dialog.Abstract = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Size
  Delegates: {
    picker: ['attach', 'detach']
  }
  Attributes: {
    class: {
      value: ''
    }
    overlay: {
      value: false
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @picker = new Core.Picker()
    @overlayEl = new Core.Overlay()
  show: ->
    @picker.set 'content', @base
    @picker.show undefined, false
    if @overlay
      document.body.grab @overlayEl
  hide: (e,force)->
    if force?
      @overlayEl.base.dispose()
      @picker.hide(e,true)
    if e?
      if @base.isVisible() and not @base.hasChild(e.target) and e.target isnt @base
        @overlayEl.base.dispose()
        @picker.hide(e)
}
