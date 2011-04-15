###
---

name: Data.Number

description: Number data element.

license: MIT-style license.

requires: 
  - Data.Abstract
  - Core.Slider

provides: Data.Number

...
###
Data.Number = new Class {
  Extends: Core.Slider
  Attributes: {
    class: {
      value: Lattice.buildClass 'number'
      setter: (value, old, self) ->
        self::parent.call @, value, old, self::parent
        @textLabel.replaceClass "#{value}-text", "#{old}-text"
        value
    }
    range: {
      value: 0
    }
    reset: {
      value: true
    }
    steps: {
      value: 100
    }
    label: {
      value: null
    }
  }
  create: ->
    @parent()
    @textLabel = new Element "div"
    @textLabel.setStyles {
      position: 'absolute'
      bottom: 0
      left: 0
      right: 0
      top: 0
    }
    @base.grab @textLabel
    @addEvent 'step', (e) =>
      @fireEvent 'change', e
  update: ->
    @textLabel.set 'text', if @label? then @label + " : " + @value else @value
}
