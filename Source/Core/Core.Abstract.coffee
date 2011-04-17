###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: 
  - Class.Extras
  - Element.Extras
  - Lattice
  - Interfaces.Mux

provides: Core.Abstract

...
###
Core.Abstract = new Class {
  Implements:[
    Events
    Interfaces.Mux
  ]
  Delegates: {
    base: ['setStyle','getStyle','setStyles','getStyles','dispose']
  }
  Attributes: {
    class: {
      setter: (value, old) ->
        value = String.from value
        @base.replaceClass value, old
        value
    }
  }
  getSize: ->
    comp = @base.getComputedSize({styles:['padding','border','margin']})
    {x:comp.totalWidth, y:comp.totalHeight}
  initialize: (attributes) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes attributes
    Lattice.Elements.push @
    @
  create: ->
  update: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
}
