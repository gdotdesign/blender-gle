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
Blender.Toolbar = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-toolbar'
    }
  }
  create: ->
    @select = new Data.Select({editable:false,size:80});
    @addChild @select
}
