###
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

...
###
Interfaces.Enabled = new Class {
  _$Enabled: ->
    @addAttributes {
      enabled: {
        value: true
        setter: (value) ->
          if value
            if @children?
              @children.each (item) ->
                if item.$attributes.enabled?
                  item.set 'enabled', true
            @base.removeClass 'disabled'
          else
            if @children?
              @children.each (item) ->
                if item.$attributes.enabled?
                  item.set 'enabled', false
            @base.addClass 'disabled'
          value
      }
    }
}
