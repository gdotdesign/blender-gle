###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - G.UI/Interfaces.Size
  
provides: Data.Text

...
###
Data.Text = new Class {
  Extends: Data.Abstract
  Implements: Interfaces.Size
  Binds: ['update']  
  Attributes: {
    class: {
      value: 'blender-textarea'
    }
    value: {
      setter: (value) ->
        @text.set 'value', value
        value
      getter: ->
        @text.get 'value'
    }
  }
  update: ->
    @fireEvent 'change', @get 'value'
    @text.setStyle 'width', @size-10
  create: ->
    @text = new Element 'textarea'
    @base.grab @text
    @text.addEvent 'keyup', @update
    
}