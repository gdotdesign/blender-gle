###
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: 'dialog-prompt'
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
    labelClass: {
      value: 'dialog-prompt-label'
      setter: (value, old) ->
        value = String.from value
        @labelDiv.removeClass old
        @labelDiv.addClass value
        value
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
