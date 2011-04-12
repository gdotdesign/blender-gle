###
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Controls

requires: 
  - Interfaces.Enabled

...
###
Interfaces.Controls = new Class {
  Implements: Interfaces.Enabled
  show: ->
    if @enabled
      @base.show()
  hide: ->
    if @enabled
      @base.hide()
  toggle: ->
    if @enabled
      @base.toggle()
}
