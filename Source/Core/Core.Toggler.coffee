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
      value: Lattice.buildClass 'button-toggle'
    }
    onLabel: {
      value: 'ON'
      setter: (value) ->
        @onDiv.set 'text', value
    }
    offLabel: {
      value: 'OFF'
      setter: (value) ->
        @offDiv.set 'text', value
    }
    onClass: {
      value: 'on'
      setter: (value, old) ->
        @onDiv.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
    offClass: {
      value: 'off'
      setter: (value, old) ->
        @offDiv.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
    separatorClass: {
      value: 'separator'
      setter: (value, old) ->
        @separator.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
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
    
    @base.addEvent 'click', =>
       if @enabled
         if @checked
          @set 'checked', no
         else
          @set 'checked', yes
    
}
