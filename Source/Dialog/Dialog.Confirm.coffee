###
---

name: Dialog.Confirm

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Confirm

...
###
Dialog.Confirm = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-confirm'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @labelDiv.replaceClass "#{value}-label", "#{old}-label"
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @labelDiv.set 'text', value
    }
    okLabel: {
      value: 'Ok'
      setter: (value) ->
        @okButton.set 'label', value
    }
    cancelLabel: {
      value: 'Cancel'
      setter: (value) ->
        @cancelButton.set 'label', value
    }
  }
  update: ->
    @labelDiv.setStyle 'width', @size
    @okButton.set 'size', @size/2
    @cancelButton.set 'size', @size/2
    oksize = @okButton.getSize().x
    cancelsize = @cancelButton.getSize().x
    @base.setStyle 'width', oksize+cancelsize
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @okButton = new Buttons.Abstract()
    @cancelButton = new Buttons.Abstract()
    $$(@okButton.base, @cancelButton.base).setStyle 'float', 'left'
    @base.adopt @labelDiv, @okButton, @cancelButton, new Element('div',{style:"clear: both"})
    @okButton.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', [@,e]
      @hide(e,true)
    @cancelButton.addEvent 'invoked', (el,e) =>
      @fireEvent 'cancelled', [@,e]
      @hide(e,true)
}
