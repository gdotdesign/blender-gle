###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: 
  - Data.Abstract
  - Interfaces.Size
  
provides: Data.Text

...
###
Data.Text = new Class {
  Extends: Data.Abstract
  Implements: Interfaces.Size
  Binds: ['update']  
  Attributes: {
    class: {
      value: Lattice.buildClass 'textarea'
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
