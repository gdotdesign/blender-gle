###
---

name: Blender.Toolbar

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Data.Select

provides: Blender.Toolbar

...
###
Interfaces.HorizontalChildren = new Class {
  Extends: Interfaces.Children
  addChild: (el, where) ->
    @children.push el
    document.id(el).setStyle 'float', 'left'
    @base.grab el, where
}
Blender.Toolbar = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.HorizontalChildren
  Attributes: {
    class: {
      value: 'blender-toolbar'
    }
    content: {
      value: null
      setter: (newVal,oldVal)->
        @removeChild oldVal
        @addChild newVal, 'top'
        newVal
    }
  }
  create: ->
    @select = new Data.Select({editable:false,size:80});
    @addChild @select
}
