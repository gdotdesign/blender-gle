###
---

name: Core.Toggler

description: iOs style checkbox element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

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
      value: Lattice.buildClass 'toggler'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @onDiv.replaceClass "#{value}-on", "#{old}-on"
        @offDiv.replaceClass "#{value}-off", "#{old}-off"
        @separator.replaceClass "#{value}-separator", "#{old}-separator"
        value
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
    checked: {
      value: on
      setter: (value) ->
        @fireEvent 'invoked', [@,value]
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
