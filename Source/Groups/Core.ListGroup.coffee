Core.ListGroup = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Size
    Interfaces.Children
  ]
  Attributes: {
    class: {
      value: 'blender-list-group'
    }
  }
  create: ->
    @parent()
    @base.setStyle 'position', 'relative'
  update: ->
    length = @children.length
    if length > 0
      cSize = @size/length
      lastSize = @size-(cSize*(length-1))
      @children.each (child,i) ->
        child.setStyle 'position','absolute'
        child.setStyle 'top', 0
        child.setStyle 'left', cSize*i-1
        child.set 'size', cSize
      @children.getLast().set 'size', lastSize
    
}
