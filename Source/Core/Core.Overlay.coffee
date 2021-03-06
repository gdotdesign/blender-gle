###
---

name: Core.Overlay

description: Overlay for modal dialogs and stuff.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled

provides: Core.Overlay

...
###
Core.Overlay = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Controls
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Overlay.class
    }
    zindex: {
      value: 0
      setter: (value) ->
        @base.setStyle 'z-index', value
        value
      validator: (value) ->
        typeOf(Number.from(value)) is 'number'
    }
  }
  create: ->
    @base.setStyles {
      position:"fixed"
      top:0
      left:0
      right:0
      bottom:0
    }
    @hide()
    
}
