###
---

name: Buttons.Key

description: Button for shortcut editing.

license: MIT-style license.

requires: 
  - Buttons.Abstract

provides: Buttons.Key

...
###
Buttons.Key = new Class {
  Extends: Buttons.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'button-key'
    }
  }
  getShortcut: (e) ->
    @specialMap = {
      '~':'`', '!':'1', '@':'2', '#':'3',
      '$':'4', '%':'5', '^':'6', '&':'7',
      '*':'8', '(':'9', ')':'0', '_':'-',
      '+':'=', '{':'[', '}':']', '\\':'|',
      ':':';', '"':'\'', '<':',', '>':'.',
      '?':'/'
    }
    modifiers = ''
    if e.control
      modifiers += 'ctrl ' 
    if event.meta
      modifiers += 'meta '
    if e.shift
      specialKey = @specialMap[String.fromCharCode(e.code)]
      if specialKey?
        e.key = specialKey
      modifiers += 'shift '
    if e.alt
      modifiers += 'alt '
    modifiers + e.key
  create: ->
    stop = (e) ->
      e.stop()
    @base.addEvent 'click', (e) =>
      if @enabled
        @set 'label', 'Press any key!'
        @base.addClass 'active'
        window.addEvent 'keydown', stop
        window.addEvent 'keyup:once', (e) =>
          @base.removeClass 'active'
          shortcut = @getShortcut(e).toUpperCase()
          if shortcut isnt "ESC"
            @set 'label', shortcut
            @fireEvent 'invoked', [@,shortcut]
          window.removeEvent 'keydown', stop
}
