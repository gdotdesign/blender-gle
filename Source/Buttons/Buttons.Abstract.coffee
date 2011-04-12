###
---

name: Buttons.Abstract

description: Button element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Buttons.Abstract

...
###
Buttons.Abstract = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: Lattice.buildClass 'button'
    }
  }
  create: ->
    @base.addEvent 'click', (e) =>
      if @enabled
        @fireEvent 'invoked', [@, e]
}
