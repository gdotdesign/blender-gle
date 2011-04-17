###
---

name: Dialog.Alert

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Alert

...
###
Dialog.Alert = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-alert'
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
    buttonLabel: {
      value: 'Ok'
      setter: (value) ->
        @button.set 'label', value
    }
  }
  update: ->
    update: ->
    @labelDiv.setStyle 'width', @size
    @button.set 'size', @size
    @base.setStyle 'width', 'auto'
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @button = new Buttons.Abstract()
    @base.adopt @labelDiv, @button
    @button.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', [@,e]
      @hide(e,true)
}
