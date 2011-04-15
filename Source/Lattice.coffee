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


Lattice = new Class.Singleton {
  Elements: []
  Prefix: 'blender'
  Selectors: {}
  initialize: ->
    Array.from(document.styleSheets).each (stylesheet) =>
      if stylesheet.cssRules?
        Array.from(stylesheet.cssRules).each (rule) =>
          try 
            sexp = Slick.parse(rule.selectorText)
            for exp in sexp.expressions
              if exp[0].pseudos is undefined and exp[0].combinator is " " and exp[0].classList isnt undefined and exp.length is 1
                if exp[0].classList[0].test new RegExp("^#{@Prefix}")
                  sel = exp[0].classList.join('.') 
                  if @Selectors[sel] is undefined
                    @Selectors[sel] = {}
                  Array.from(rule.style).each (style) =>
                    @Selectors[sel][style] = rule.style.getPropertyValue(style)
          catch e
            if console?
              if console.log?
                console.log e
    @
  changePrefix: (newPrefix) ->
    @Elements.each (el) =>
      a = el.class.split('-')
      cls = a.erase(a[0]).join('-')
      @Prefix = newPrefix
      el.set 'class', @buildClass cls
    null
  buildClass: (cls) ->
    @Prefix + "-" + cls
  getCSS: (selector,property) ->
    if selector.test /^\./
      selector = selector.slice 1, selector.length
    if @Selectors[selector]?
      @Selectors[selector][property] or null
}
