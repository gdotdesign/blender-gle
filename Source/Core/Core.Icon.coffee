###
---

name: Core.Icon

description: Icon element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls 
  - Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    image: {
      setter: (value) ->
        @base.setStyle 'background-image', 'url(' + value + ')'
        value
    }
    class: {
      value: Lattice.buildClass 'icon'
    }
  }
  create: ->
    @base.addEvent 'click', (e) =>
      if @enabled
        @fireEvent 'invoked', [@, e]
}
