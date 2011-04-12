###
---

name: Groups.Abstract

description: 

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  
provides: Groups.Abstract
...
###
Groups = {}
Groups.Abstract = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  addItem: (el,where) ->
    @addChild el, where
  removeItem: (el) ->
    @removeChild el
    
}
