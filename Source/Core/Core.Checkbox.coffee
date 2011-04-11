###
---

name: Core.Checkbox

description: Blender style checkboxes

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

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
    @sign.addClass "#{@get('class')}-sign"
    @textNode = document.createTextNode ''
    @base.adopt @sign, @textNode
    @base.addEvent 'click', =>
       if @enabled
         if @state
          @set 'state', no
         else
          @set 'state', yes
}
