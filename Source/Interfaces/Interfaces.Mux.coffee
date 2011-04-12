###
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

...
###
Interfaces.Mux = new Class {
  mux: ->
    new Hash(@).each (value,key) ->
      if key.test(/^_\$/) and typeOf(value) is "function"
        value.attempt null, @
    , @
}
