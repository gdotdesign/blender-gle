###
---

name: Core.Checkbox

description: Checkbox element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Checkbox

...
###
Core.Checkbox = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'checkbox'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @sign.replaceClass "#{value}-sign", "#{old}-sign"
        value
    }
    state: {
      value: on
      setter: (value, old) ->
        if value
          @base.addClass 'checked'
        else
          @base.removeClass 'checked'
        if value isnt old
          @fireEvent 'invoked', [@,value]
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @textNode.textContent = value
        value
    }
  }
  create: ->
    @sign = new Element 'div'
    @textNode = document.createTextNode ''
    @base.adopt @sign, @textNode
    @base.addEvent 'click', =>
      if @enabled
        @set 'state', if @state then false else true
}
