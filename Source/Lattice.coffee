###
---

name: Lattice

description: Lattice 

license: MIT-style license.

provides: Lattice

requires: 
  - Class.Extras
  - Element.Extras

...
###
Interfaces = {}
Groups = {}
Buttons = {}
Layout = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}
Dialog = {}


Lattice = {}
Lattice.Elements = []
Lattice.Prefix = 'blender'
Lattice.changePrefix = (newPrefix) ->
  @Elements.each (el) =>
    a = el.class.split('-')
    cls = a.erase(a[0]).join('-')
    @Prefix = newPrefix
    el.set 'class', @buildClass cls
  null
Lattice.buildClass = (cls) ->
  Lattice.Prefix + "-" + cls
Lattice.getCSS = (selector,property) ->
  if Lattice.selectors[selector]?
    Lattice.selectors[selector][property] or null
Lattice.selectors = ( ->
  selectors = {}
  Array.from(document.styleSheets).each (stylesheet) ->
    try 
      if stylesheet.cssRules?
        Array.from(stylesheet.cssRules).each (rule) ->
          selectors[rule.selectorText] = {}
          Array.from(rule.style).each (style) ->
            selectors[rule.selectorText][style] = rule.style.getPropertyValue(style)
  selectors
)()

