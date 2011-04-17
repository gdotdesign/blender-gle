###
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract
  - Data.Text

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-prompt'
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
    @input.set 'size', @size
    @base.setStyle 'width', 'auto'
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @input = new Data.Text()
    @button = new Buttons.Abstract()
    @base.adopt @labelDiv, @input, @button
    @button.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', @input.get('value')
      @hide(e,true)
}
