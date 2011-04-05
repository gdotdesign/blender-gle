###
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - Core.Button

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends:Core.Abstract
  Delegates: {
    picker: ['show','hide','attach']
  }
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
  initialize: (options) ->
    @parent options
  create: ->
    @labelDiv = new Element 'div'
    @input = new Element 'input',{type:'text'}
    @button = new Core.Button()
    @base.adopt @labelDiv, @input, @button
    @picker = new Core.Picker()
    @picker.set 'content', @base
    @button.addEvent 'invoked', ((el,e)->
      @fireEvent 'invoked', @input.get('value')
    ).bind @
}
