###
---

name: Interfaces.Children

description: 

license: MIT-style license.

provides: Interfaces.Children

...
###
Interfaces.Children = new Class {
  _$Children: ->
    @children = []
  hasChild: (child) ->
    if @children.indexOf(child) >= 0 then yes else no
  adoptChildren: ->
    children = Array.from arguments 
    children.each (child) ->
      @addChild child
    , @
  addChild: (el, where) ->
    @children.push el
    @base.grab el, where
  removeChild: (el) ->
    if @children.contains(el)
      @children.erase el
      document.id(el).dispose()
      delete el
  empty: ->
    @children.each (child) ->
      document.id(child).dispose()
    @children.empty()
}
