###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: 
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls 
  - G.UI/Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
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
