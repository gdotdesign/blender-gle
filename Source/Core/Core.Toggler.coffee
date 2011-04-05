###
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Core.Toggler

...
###
Core.Toggler = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: GDotUI.Theme.Toggler.class
    }
    onLabel: {
      value: GDotUI.Theme.Toggler.onText
      setter: (value) ->
        @onDiv.set 'text', value
    }
    offLabel: {
      value: GDotUI.Theme.Toggler.offText
      setter: (value) ->
        @offDiv.set 'text', value
    }
    onClass: {
      value: GDotUI.Theme.Toggler.onClass
      setter: (value, old) ->
        @onDiv.removeClass old
        @onDiv.addClass value
        value
    }
    offClass: {
      value: GDotUI.Theme.Toggler.offClass
      setter: (value, old) ->
        @offDiv.removeClass old
        @offDiv.addClass value
        value
    }
    separatorClass: {
      value: GDotUI.Theme.Toggler.separatorClass
      setter: (value, old) ->
        @separator.removeClass old
        @separator.addClass value
        value
    }
    checked: {
      value: on
      setter: (value) ->
        @fireEvent 'change', value
        value
    }
  }
  update: ->
    if @size
      $$(@onDiv,@offDiv,@separator).setStyles {
        width: @size/2
      }
      @base.setStyle 'width', @size
    if @checked
      @separator.setStyle 'left', @size/2
    else
      @separator.setStyle 'left', 0
    @offDiv.setStyle 'left', @size/2
  create: ->
    @base.setStyle 'position','relative'
    @onDiv = new Element 'div'
    @offDiv = new Element 'div'
    @separator = new Element 'div', {html: '&nbsp;'}
    @base.adopt @onDiv, @offDiv, @separator

    $$(@onDiv,@offDiv,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    
    @base.addEvent 'click', ( ->
       if @enabled
         if @checked
          @set 'checked', no
         else
          @set 'checked', yes
    ).bind @
    
}
