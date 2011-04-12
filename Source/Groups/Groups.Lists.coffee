###
---

name: Groups.Lists

description: 

license: MIT-style license.

requires: 
  - Groups.Abstract
  - Interfaces.Size
  
provides: Groups.Lists

...
###
Groups.Lists = new Class {
  Extends: Groups.Abstract
  Implements: [
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'list-group'
    }
  }
  create: ->
    @parent()
    @base.setStyle 'position', 'relative'
  update: ->
    length = @children.length
    if length > 0
      cSize = @size/length
      lastSize = Math.floor(@size-(cSize*(length-1)))
      @children.each (child,i) ->
        child.base.setStyle 'position','absolute'
        child.base.setStyle 'top', 0
        child.base.setStyle 'left', cSize*i-1
        child.set 'size', cSize
      @children.getLast().set 'size', lastSize
    
}
