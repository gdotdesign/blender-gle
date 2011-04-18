###
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
###
Element.Properties.checked = {
  get: ->
    if @getChecked?
      @getChecked()
  set: (value) ->
    @setAttribute 'checked', value
    if @on? and @off?
      if value
        @on()
      else
        @off()
}
( ->
  Number.implement {
    inRange: (center,range) ->
      if center-range < @ < center+range
        true
      else
        false
  }
  Number.eval = (string,size) ->
    Number.from(eval(String.from(string).replace /(\d*)\%/g, (match,str) ->
      (Number.from(str)/100)*size
    ))
)()
( ->
  Color.implement {
    type: 'hex'
    alpha: 100
    setType: (type) ->
      @type = type
    setAlpha: (alpha) ->
      @alpha = alpha
    hsvToHsl: ->
      h = @hsb[0]
      s = @hsb[1]
      v = @hsb[2]
      l = (2 - s / 100) * v / 2;
      hsl = [
        h
        s * v / (if l < 50 then l * 2 else 200 - l * 2)
        l
      ]
      if isNaN(hsl[1]) then hsl[1] = 0
      hsl
    format: (type) ->
      if type then @setType(type)
      switch @type
        when "rgb"
          String.from "rgb(#{@rgb[0]}, #{@rgb[1]}, #{@rgb[2]})"
        when "rgba"
          String.from "rgba(#{@rgb[0]}, #{@rgb[1]}, #{@rgb[2]}, #{@alpha/100})"
        when "hsl"
          @hsl = @hsvToHsl()
          String.from "hsl(#{@hsl[0]}, #{Math.round(@hsl[1])}%, #{Math.round(@hsl[2])}%)"
        when "hsla"
          @hsl = @hsvToHsl()
          String.from "hsla(#{@hsl[0]}, #{Math.round(@hsl[1])}%, #{Math.round(@hsl[2])}%, #{@alpha/100})"
        when "hex"
          String.from @hex
  }
)()
( ->
  oldPrototypeStart = Drag::start
  Drag.prototype.start = ->
    window.fireEvent 'outer'
    oldPrototypeStart.run arguments, @
)()
(->
  Element.Events.outerClick = {
    base: 'mousedown'
    condition: (event) ->
      event.stopPropagation()
      off
    onAdd: (fn) ->
      window.addEvent 'click', fn
      window.addEvent 'outer', fn
    onRemove: (fn) ->
      window.removeEvent 'click', fn
      window.removeEvent 'outer', fn
  }
  Element.implement {
    replaceClass: (newClass,oldClass) ->
      @removeClass oldClass
      @addClass newClass
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
    oldPosition: Element::position
    position: (options) ->
      if options.relativeTo isnt undefined
        op = {
          relativeTo: document.body
          position: {x:'center',y:'center'}
        }
        options = Object.merge op, options
        winsize = window.getSize()
        winscroll = window.getScroll()
        asize = options.relativeTo.getSize()
        position = options.relativeTo.getPosition()
        size = @getSize()
        if options.position.x is 'auto' 
          if (position.x+size.x+asize.x) > (winsize.x-winscroll.x) then options.position.x = 'left' else options.position.x = 'right'          
        if options.position.y is 'auto'
          if (position.y+size.y+asize.y) > (winsize.y-winscroll.y) then options.position.y = 'top' else options.position.y = 'bottom'
        
        
        ofa = {x:0,y:0}
        switch options.position.x
          when 'center'
            if options.position.y isnt 'center'
              ofa.x = -size.x/2
          when 'left'
            ofa.x = -(options.offset+size.x)
          when 'right'
            ofa.x = options.offset
        switch options.position.y
          when 'center'
            if options.position.x isnt 'center'
              ofa.y = -size.y/2
          when 'top'
            ofa.y = -(options.offset+size.y)
          when 'bottom'
            ofa.y = options.offset
         options.offset = ofa
        else
          options.relativeTo = document.body
          options.position = {x:'center',y:'center'}
          if typeOf options.offset isnt 'object'
            options.offset = {x:0,y:0}
        @oldPosition.attempt options, @
    removeTransition: ->
      @store 'transition', @getStyle( '-webkit-transition-duration' )
      @setStyle '-webkit-transition-duration', '0'
      
    addTransition: ->
      @setStyle '-webkit-transition-duration', @retrieve( 'transition' )
      @eliminate 'transition'
      
    inTheDom: ->
      if @parentNode
        if @parentNode.tagName.toLowerCase() is "html"
          true
        else
          $(@parentNode).inTheDom
      else
        false
        
    grab: (el, where) ->
      @oldGrab.attempt arguments, @
      e = document.id(el)
      if e.fireEvent?
        e.fireEvent 'addedToDom'
      @
      
    inject: (el, where) ->
      @oldInject.attempt arguments, @
      @fireEvent 'addedToDom'
      @
      
    adopt: ->
      @oldAdopt.attempt arguments, @
      elements = Array.flatten(arguments)
      elements.each (el) ->
        e = document.id(el)
        if e.fireEvent?
          document.id(el).fireEvent 'addedToDom'
      @
  }
)()

###
---
name: Class.Extras
description: Extra suff for Classes.

license: MIT-style

authors:
  - Kevin Valdek
  - Perrin Westrich
  - Maksim Horbachevsky
provides:
  - Class.Extras
...
###
Class.Singleton = new Class {
	initialize: (classDefinition, options) ->
		singletonClass = new Class(classDefinition)
		new singletonClass(options)
}

Class.Mutators.Delegates = (delegations) ->
  new Hash(delegations).each (delegates, target) ->
    $splat(delegates).each (delegate) ->
      @::[delegate] = ->
        ret = @[target][delegate].apply @[target], arguments
        if ret is @[target] then @ else ret
    , @
  , @


mergeOneNew = (source, key, current) ->
	switch typeOf(current)
		when 'object'
			if (typeOf(source[key]) == 'object') 
			  Object.mergeNew(source[key], current)
			else 
			  source[key] = Object.clone(current)
		when 'array'
		  source[key] = current.clone()
		when 'function'
		  current::parent = source[key]
		  source[key] = current
		else
		  source[key] = current
	source
	
Object.extend {
	mergeNew: (source, k, v) ->
		if typeOf(k) == 'string'
		  return mergeOneNew(source, k, v)
		for i in [1..arguments.length-1]
			object = arguments[i]
			Object.each object, (value,key) ->
			  mergeOneNew(source, key, value)
		source
}
Class.Mutators.Attributes = (attributes) ->
    $setter = attributes.$setter
    $getter = attributes.$getter
    
    if @::$attributes
      attributes = Object.mergeNew @::$attributes, attributes
    delete attributes.$setter
    delete attributes.$getter

    @implement new Events

    @implement {
      $attributes: attributes
      get: (name) ->
        attr = @$attributes[name]
        if attr 
          if attr.valueFn && !attr.initialized
            attr.initialized = true
            attr.value = attr.valueFn.call @
          if attr.getter
            return attr.getter.call @, attr.value
          else
            return attr.value
        else
          return if $getter then $getter.call(@, name) else undefined
      set: (name, value) ->
        attr = @$attributes[name]
        if attr
          if !attr.readOnly
            oldVal = attr.value
            if !attr.validator or attr.validator.call(@, value)
              if attr.setter
                newVal = attr.setter.call @, value, oldVal, attr.setter
              else
                newVal = value             
              attr.value = newVal
              @[name] = newVal
              #if attr.update
              @update()
              if oldVal isnt newVal
                  @fireEvent name + 'Change', { newVal: newVal, oldVal: oldVal }
              newVal
        else if $setter
          $setter.call @, name, value

      setAttributes: (attributes) ->
        attributes = Object.merge {}, attributes
        Object.each @$attributes, (value,name) ->
          if attributes[name]?
            @set name, attributes[name]
          else if value.value?
            @set name, value.value
        , @

      getAttributes: () ->
        attributes = {}
        $each(@$attributes, (value, name) ->
          attributes[name] = @get(name)
        , @)
        attributes

      addAttributes: (attributes) ->
        $each(attributes, (value, name) ->
            @addAttribute(name, value)
        , @)

      addAttribute: (name, value) ->
        @$attributes[name] = value
        @
  }

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

###
---

name: Core.Abstract

description: Abstract base class for Core U.I. elements.

license: MIT-style license.

requires: 
  - Class.Extras
  - Element.Extras
  - Lattice
  - Interfaces.Mux

provides: Core.Abstract

...
###
Core.Abstract = new Class {
  Implements:[
    Events
    Interfaces.Mux
  ]
  Delegates: {
    base: ['setStyle','getStyle','setStyles','getStyles','dispose']
  }
  Attributes: {
    class: {
      setter: (value, old) ->
        value = String.from value
        @base.replaceClass value, old
        value
    }
  }
  getSize: ->
    comp = @base.getComputedSize({styles:['padding','border','margin']})
    {x:comp.totalWidth, y:comp.totalHeight}
  initialize: (attributes) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes attributes
    Lattice.Elements.push @
    @
  create: ->
  update: ->
  ready: ->
    @base.removeEvents 'addedToDom'
  toElement: ->
    @base
}

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

###
---

name: Interfaces.Size 

description: Size minsize from css

license: MIT-style license.

provides: Interfaces.Size 

...
###
Interfaces.Size = new Class {
  _$Size: ->
    @size = Number.from Lattice.getCSS ".#{@get('class')}", 'width' or 0
    @minSize = Number.from Lattice.getCSS ".#{@get('class')}", 'min-width' or 0
    @addAttribute 'minSize', {
      value: null
      setter: (value,old) ->
        @base.setStyle 'min-width', value
        if @size < value
          @set 'size', value
        value      
    }
    @addAttribute 'size', {
      value: null
      setter: (value, old) ->
        size = if value < @minSize then @minSize else value
        @base.setStyle 'width', size
        size
    }
  
}

###
---

name: Core.Checkbox

description: Checkbox element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Checkbox

...
###
Core.Checkbox = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'checkbox'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @sign.replaceClass "#{value}-sign", "#{old}-sign"
        value
    }
    state: {
      value: on
      setter: (value, old) ->
        if value
          @base.addClass 'checked'
        else
          @base.removeClass 'checked'
        if value isnt old
          @fireEvent 'invoked', [@,value]
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @textNode.textContent = value
        value
    }
  }
  create: ->
    @sign = new Element 'div'
    @textNode = document.createTextNode ''
    @base.adopt @sign, @textNode
    @base.addEvent 'click', =>
      if @enabled
        @set 'state', if @state then false else true
}

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

###
---

name: Core.Icon

description: Icon element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls 
  - Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    image: {
      setter: (value) ->
        @setStyle 'background-image', 'url(' + value + ')'
        value
    }
    class: {
      value: Lattice.buildClass 'icon'
    }
  }
  create: ->
    @base.addEvent 'click', (e) =>
      if @enabled
        @fireEvent 'invoked', [@, e]
}

###
---

name: Core.Tip

description: Tip.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Enabled

provides: Core.Tip

...
###
Core.Tip = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Enabled
  Binds:[
    'enter'
    'leave'
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'tip'
    }
    label: {
      value: ''
      setter: (value) ->
        @base.set 'html', value
    }
    zindex: {
      value: 1
      setter: (value) ->
        @base.setStyle 'z-index', value
    }
    delay: {
      value: 0
    }
    location: {
      value: {x:'center',y:'center'}
    }
    offset: {
      value: 0
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  attach: (item) ->
    if @attachedTo?
      @detach()
    @attachedTo = document.id(item)
    @attachedTo.addEvent 'mouseenter', @enter
    @attachedTo.addEvent 'mouseleave', @leave
  detach: ->
    @attachedTo.removeEvent 'mouseenter', @enter
    @attachedTo.removeEvent 'mouseleave', @leave
    @attachedTo = null
  enter: ->
    if @enabled
      @over = true
      @id = ( ->
        if @over
          @show()
      ).bind(@).delay @delay
  leave: ->
    if @enabled
      if @id?
        clearTimeout(@id)
        @id = null
      @over = false
      @hide()
  ready: ->
    if @attachedTo?
      @base.position {
        relativeTo: @attachedTo
        position: @location
        offset: @offset
      }
  hide: ->
    @base.dispose()
  show: ->
    document.getElement('body').grab(@base)
}

###
---

name: Core.Slider

description: Slider element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled

provides: Core.Slider

...
###
Core.Slider = new Class {
  Extends:Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'slider'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @progress.replaceClass "#{value}-progress", "#{old}-progress"
        value
    }
    reset: {
      value: off
    }
    steps: {
      value: 100
    }
    range: {
      value: [0,0]
    }
    mode: {
      value: 'horizontal'
      setter: (value, old) ->
        @base.removeClass old
        @base.addClass value
        @base.set 'style', ''
        @base.setStyle 'position', 'relative'
        switch value
          when 'horizontal'
            @minSize = Number.from Lattice.getCSS ".#{@class}.horizontal", 'min-width'
            @modifier = 'width'
            @drag.options.modifiers = {x: 'width',y:''}
            @drag.options.invert = false
            if not @size?
              size = Number.from Lattice.getCSS ".#{@class}.horizontal", 'width'
            @set 'size', size
            @progress.set 'style', ''
            @progress.setStyles {
              position: 'absolute'
              top: 0
              bottom: 0
              left: 0
            } 
          when 'vertical'
            @minSize = Number.from Lattice.getCSS ".#{@class}.vertical", 'min-height'
            @modifier = 'height'
            @drag.options.modifiers = {x: '',y: 'height'}
            @drag.options.invert = true
            if not @size?
              size = Number.from Lattice.getCSS ".#{@class}.vertical", 'height'
            @set 'size', size
            @progress.set 'style', ''
            @progress.setStyles {
              position: 'absolute'
              bottom: 0
              left: 0
              right: 0
            }
        if @base.isVisible()
          @set 'value', @value
        value
    }
    value: {
      value: 0
      setter: (value) ->
        value = Number.from value
        if !@reset
          percent = Math.round((value/@steps)*100)
          if value < 0
            @progress.setStyle @modifier, 0
            value = 0
          if @value > @steps
            @progress.setStyle @modifier, @size
            value = @steps
          if not(value < 0) and not(value > @steps)
            @progress.setStyle @modifier, (percent/100)*@size
        value
      getter:  ->
        if @reset
          @value
        else
          Number.from(@progress.getStyle(@modifier))/@size*@steps
    }
    size: {
      setter:  (value, old) ->
        if !value?
          value = old
        if @minSize > value
          value = @minSize
        @base.setStyle @modifier, value
        @progress.setStyle @modifier, if @reset then value/2 else @value/@steps*value
        value
    }
    
  }
  onDrag: (el,e) ->
    if @enabled
      pos = Number.from el.getStyle(@modifier)
      offset = Math.round((pos/@size)*@steps)-@lastpos
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if pos > @size
        el.setStyle @modifier, @size
        pos = @size
      else
        if @reset
          @value += offset
      if not @reset
        @value = Math.round((pos/@size)*@steps)
      @fireEvent 'step', @value
      @update()
    else
      el.setStyle @modifier, @disabledTop
  create: ->
    @progress = new Element "div"
         
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base}
    
    @drag.addEvent 'beforeStart', (el,e) =>
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if not @enabled
        @disabledTop = el.getStyle @modifier
        
    @drag.addEvent 'complete', (el,e) =>
      if @reset
        if @enabled
          el.setStyle @modifier, @size/2+"px"
      @fireEvent 'complete'
      
    @drag.addEvent 'drag', @onDrag.bind @
    
    @base.addEvent 'mousewheel', (e) =>
      e.stop()
      if @enabled
        @set 'value', @value+Number.from(e.wheel)
        @fireEvent 'step', @value

}

###
---

name: Core.Scrollbar

description: Scrollbar element.

license: MIT-style license.

requires: 
  - Core.Slider
  
provides: Core.Scrollbar

...
###
Core.Scrollbar = new Class {
  Extends: Core.Slider
  Attributes: {
    mode: {
      setter: (value, old, self) ->
        self::parent.call @, value, old
        switch value
          when 'horizontal'
            @smodif = 'left'
            @drag.options.modifiers = {
              x:'left'
              y:''
            }
          when 'vertical'
            @smodif = 'top'
            @drag.options.modifiers = {
              x:''
              y:'top'
            }
            @drag.options.invert = false
        value
    }
    value: {
      getter: ->
        if @reset
          @value
        else
          width = @size-@progressSize
          Number.from(@progress.getStyle(@smodif)) / width * @steps
      setter: (value) ->
        value = Number.from value
        width = @size-@progressSize
        if !@reset
          percent = Math.round((value/@steps)*100)
          if value < 0
            @progress.setStyle @smodif, 0
            value = 0
          else if value > @steps
            @progress.setStyle @smodif, width
            value = @steps
          else if not(value < 0) and not(value > @steps)
            @progress.setStyle @smodif, (percent/100)*width
        value
    }
    size: {
      setter: (value, old) ->
        if !value?
          value = old
        else
          value = Number.from value
        if @minSize > value
          value = @minSize
        @base.setStyle @modifier, value
        @progress.setStyle @modifier, (value*0.7)
        @progressSize = (value*0.7)
        value
    }
  }
  create: ->
    @parent()
  onDrag: (el,e) ->
    if @enabled
      left = Number.from(@progress.getStyle(@smodif))
      width = @size-@progressSize
      if left < @size-@progressSize
        @value = left/width*@steps
      else  
        el.setStyle @smodif, @size-@progressSize
        @value = @steps
      if left < 0
        el.setStyle @smodif, 0
        @value = 0
      @fireEvent 'step', Math.round(@value)
    else
      @set 'value', @value
    
}

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

###
---

name: Core.Picker

description: Generic Picker.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Enabled

provides: Core.Picker
...
###
Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Enabled
  ]
  Binds: ['show','hide','delegate']
  Attributes: {
    class: {
      value: Lattice.buildClass 'picker'
    }
    offset: {
      value: 0
      setter: (value) ->
        value
    }
    position: {
      value: {x:'auto',y:'auto'}
      validator: (value) ->
        value.x? and value.y?
    }
    content: {
      value: null
      setter: (value, old)->
        if old?
          if old["$events"]
            old.removeEvent 'change', @delegate
          @removeChild old
        @addChild value
        if value["$events"]
          value.addEvent 'change', @delegate
        value
    }
    picking: {
      value: 'picking'
    }
  }
  create: ->
    @base.setStyle 'position', 'absolute'
  ready: ->
    @base.position {
      relativeTo: @attachedTo
      position: @position
      offset: @offset
    }
  attach: (el,auto) ->
    auto = if auto? then auto else true
    if @attachedTo?
      @detach()
    @attachedTo = el
    if auto
      el.addEvent 'click', @show
  detach: ->
    if @attachedTo?
      @attachedTo.removeEvent 'click', @show
      @attachedTo = null
  delegate: ->
    if @attachedTo?
      @attachedTo.fireEvent 'change', arguments
  show: (e,auto) ->
    if @enabled
      auto = if auto? then auto else true
      document.body.grab @base
      if @attachedTo?
        @attachedTo.addClass @picking
      if e? then if e.stop? then e.stop()
      if auto
        @base.addEvent 'outerClick', @hide
  hide: (e,force) ->
    if @enabled
      if force?
        if @attachedTo?
            @attachedTo.removeClass @picking
          @base.dispose()
      else if e?
        if @base.isVisible() and not @base.hasChild(e.target)
          if @attachedTo?
            @attachedTo.removeClass @picking
          @base.dispose()
}

###
---

name: Iterable.List

description: List element.

license: MIT-style license.

requires:
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Size

provides: Iterable.List

...
###
Iterable.List = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'list'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @children.each (item) =>
          if item.base.hasClass @selectedClass
            item.base.removeClass @selectedClass
        @set 'selectedClass', "#{value}-selected"
        @set 'selected', @selected
        value
    }
    selectedClass: {
      value: Lattice.buildClass 'list-selected'
    }
    selected: {
      getter: ->
        @children.filter(((item) ->
          if item.base.hasClass @selectedClass then true else false
        ).bind(@))[0]
      setter: (value, old) ->
        if old
          old.base.removeClass @selectedClass
        if value?
          value.base.addClass @selectedClass
        value
        
    }
  }
  getItemFromLabel: (label) ->
    filtered = @children.filter (item) ->
      if String.from(item.label).toLowerCase() is String(label).toLowerCase()
        yes
      else no
    filtered[0]
  addItem: (li) -> 
    @addChild li
    li.addEvent 'select', (item,e) =>
      @set 'selected', item 
    li.addEvent 'invoked', (item) =>
      @fireEvent 'invoked', arguments
  removeItem: (li) ->
    if @hasChild li
      li.removeEvents 'select'
      li.removeEvents 'invoked'
      @removeChild li
}

###
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Iterable.List

provides: Core.Slot

todo: horizontal/vertical
...
###
Core.Slot = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'slot'
    }
  }
  Binds:[
    'check'
    'complete'
    'update'
    'mouseWheel'
  ]
  Delegates:{
    'list':[
      'addItem'
      'removeAll'
      'removeItem'
    ]
  }
  create: ->
    @base.setStyle 'overflow', 'hidden'
    @base.setStyle 'position', 'relative'
    
    @overlay = new Element 'div', {'text':' '}
    @overlay.addClass 'over'
    @overlay.addEvent 'mousewheel',@mouseWheel
    
    @overlay.setStyles {
      'position': 'absolute'
      'top': 0
      'left': 0
      'right': 0
      'bottom': 0
    }
    
    @list = new Iterable.List()
    @list.base.addEvent 'addedToDom', @update
    @list.addEvent 'selectedChange', (item) =>
      @update()
      @fireEvent 'change', item.newVal
    @list.setStyle 'position', 'relative'
    @list.setStyle 'top', '0'
    
    @drag = new Drag @list.base, {modifiers:{x:'',y:'top'},handle:@overlay}
    @drag.addEvent 'drag', @check
    @drag.addEvent 'beforeStart', =>
      if not @enabled
        @disabledTop = @list.base.getStyle 'top' 
      @list.base.removeTransition()
    @drag.addEvent 'complete', =>
      @dragging = off
      @update()
  ready: ->
    @base.adopt @list, @overlay
  check: (el,e) ->
    if @enabled
      @dragging = on
      lastDistance = 1000
      lastOne = null
      @list.children.each (item,i) =>
        distance = -item.base.getPosition(@base).y + @base.getSize().y/2
        if distance < lastDistance and distance > 0 and distance < @base.getSize().y/2
          @list.set 'selected', item
    else
      el.setStyle 'top', @disabledTop
  mouseWheel: (e) ->
    if @enabled
      e.stop()
      if @list.selected?
        index = @list.children.indexOf @list.selected
      else
        if e.wheel is 1
          index = 0
        else
          index = 1
      if index+e.wheel >= 0 and index+e.wheel < @list.children.length 
        @list.set 'selected', @list.children[index+e.wheel]
      if index+e.wheel < 0
        @list.set 'selected', @list.children[@list.children.length-1]
      if index+e.wheel > @list.children.length-1
        @list.set 'selected', @list.children[0]
  update: ->
    if not @dragging
      @list.base.addTransition()
      if @list.selected?
        @list.setStyle 'top',-@list.selected.base.getPosition(@list.base).y+@base.getSize().y/2-@list.selected.base.getSize().y/2
}

###
---

name: Core.Toggler

description: iOs style checkbox element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Toggler

...
###
Core.Toggler = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'toggler'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @onDiv.replaceClass "#{value}-on", "#{old}-on"
        @offDiv.replaceClass "#{value}-off", "#{old}-off"
        @separator.replaceClass "#{value}-separator", "#{old}-separator"
        value
    }
    onLabel: {
      value: 'ON'
      setter: (value) ->
        @onDiv.set 'text', value
    }
    offLabel: {
      value: 'OFF'
      setter: (value) ->
        @offDiv.set 'text', value
    }
    checked: {
      value: on
      setter: (value) ->
        @fireEvent 'invoked', [@,value]
        value
    }
  }
  update: ->
    if @size
      $$(@onDiv,@offDiv,@separator).setStyles {
        width: @size/2
      }
      @base.setStyle 'width', @size
    if @checked
      @separator.setStyle 'left', @size/2
    else
      @separator.setStyle 'left', 0
    @offDiv.setStyle 'left', @size/2
  create: ->
    @base.setStyle 'position','relative'
    @onDiv = new Element 'div'
    @offDiv = new Element 'div'
    @separator = new Element 'div', {html: '&nbsp;'}
    @base.adopt @onDiv, @offDiv, @separator

    $$(@onDiv,@offDiv,@separator).setStyles {
      'position':'absolute'
      'top': 0
      'left': 0
    }
    
    @base.addEvent 'click', =>
       if @enabled
         if @checked
          @set 'checked', no
         else
          @set 'checked', yes
    
}

###
---

name: Core.Overlay

description: Overlay for modal dialogs and alike.

license: MIT-style license.

requires:
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled

provides: Core.Overlay

...
###
Core.Overlay = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'overlay'
    }
    zindex: {
      value: 0
      setter: (value) ->
        @base.setStyle 'z-index', value
        value
      validator: (value) ->
        Number.from(value) isnt null
    }
  }
  create: ->
    @base.setStyles {
      position:"fixed"
      top:0
      left:0
      right:0
      bottom:0
    }
    @hide()
}

###
---

name: Buttons.Abstract

description: Button element.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Buttons.Abstract

...
###
Buttons.Abstract = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: Lattice.buildClass 'button'
    }
  }
  create: ->
    @base.addEvent 'click', (e) =>
      if @enabled
        @fireEvent 'invoked', [@, e]
}

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

###
---

name: Buttons.Toggle

description: Toggle button element.

license: MIT-style license.

requires: 
  - Buttons.Abstract

provides: Buttons.Toggle

...
###
Buttons.Toggle = new Class {
  Extends: Buttons.Abstract
  Attributes: {
    state: {
      value: false
      setter: (value, old) ->
        if value
          @base.addClass 'pushed'
        else
          @base.removeClass 'pushed'
        value
      getter: ->
        @base.hasClass 'pushed' 
    }
    class: {
      value: Lattice.buildClass 'button-toggle'
    }
  }
  create: ->
    @addEvent 'stateChange', ->
      @fireEvent 'invoked', [@,@state]
    @base.addEvent 'click', =>
      if @enabled
        @set 'state', if @state then false else true
}

###
---

name: Groups.Abstract

description: 

license: MIT-style license.

requires: 
  - Core.Abstract
  - Interfaces.Children
  
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

###
---

name: Groups.Icons

description: Icon group with 5 types of layout.

license: MIT-style license.

requires: 
  - Groups.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  
provides: Groups.Icons

todo: Circular center position and size
...
###
Groups.Icons = new Class {
  Extends: Groups.Abstract
  Implements: [
    Interfaces.Controls
    Interfaces.Enabled
  ]
  Binds: ['delegate']
  Attributes: {
    mode: {
      value: "horizontal"
      validator: (value) ->
        if ['horizontal','vertical','circular','grid','linear'].indexOf(value) > -1 then true else false
    }
    spacing: {
      value: {x: 0,y: 0}
      validator: (value) ->
        if typeOf(value) is 'object'
          if value.x? and value.y? then yes else no
        else no
    }
    startAngle: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a >= 0 and a <= 360
        else no
    }
    radius: {
      value: 0
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        (a = Number.from(value))?
    }
    degree: {
      value: 360
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a >= 0 and a <= 360
        else no
    }
    rows: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    columns: {
      value: 1
      setter: (value) ->
        Number.from(value)
      validator: (value) ->
        if (a = Number.from(value))?
          a > 0
        else no
    }
    class: {
      value: Lattice.buildClass 'icon-group'
    }
  }
  create: ->
    @base.setStyle 'position', 'relative'
  delegate: ->
    @fireEvent 'invoked', arguments
  addItem: (icon) ->
    if not @hasChild icon
      icon.addEvent 'invoked', @delegate
      @parent icon
      @update()
  removeItem: (icon) ->
    if @hasChild icon
      icon.removeEvent 'invoked', @delegate
      @removeChild icon
      @update()
  ready: ->
    @update()
  update: ->
    if @children.length > 0 and @mode? 
      x = 0
      y = 0
      @size = {x:0, y:0}
      spacing = @spacing
      switch @mode
        when 'grid'
          if @rows? and @columns?
            if @rows < @columns
              rows = null
              columns = @columns
            else
              columns = null
              rows = @rows
          icpos = @children.map (item,i) =>
            if rows?
              if i % rows == 0
                y = 0
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
              else
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
            if columns?
              if i % columns == 0
                x = 0
                y = if i==0 then y else y+item.base.getSize().y+spacing.y
              else
                x = if i==0 then x else x+item.base.getSize().x+spacing.x
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
        when 'linear'
          icpos = @children.map (item,i) =>
            x = if i==0 then x+x else x+spacing.x+item.base.getSize().x
            y = if i==0 then y+y else y+spacing.y+item.base.getSize().y
            @size.x = x+item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x, y:y}
        when 'horizontal'
          icpos = @children.map (item,i) =>
            x = if i==0 then x+x else x+item.base.getSize().x+spacing.x
            y = if i==0 then y else y
            @size.x = x+item.base.getSize().x
            @size.y = item.base.getSize().y
            {x:x, y:y}
        when 'vertical'
          icpos = @children.map (item,i) =>
            x = if i==0 then x else x
            y = if i==0 then y+y else y+item.base.getSize().y+spacing.y
            @size.x = item.base.getSize().x
            @size.y = y+item.base.getSize().y
            {x:x,y:y}
        when 'circular'
          n = @children.length
          radius = @radius
          startAngle = @startAngle
          ker = 2*@radius*Math.PI
          fok = @degree/n
          icpos = @children.map (item,i) ->
            if i==0
              foks = startAngle * (Math.PI/180)
              x = Math.round(radius * Math.sin(foks))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(foks))+radius/2+item.base.getSize().y
            else
              x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().x
              y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI/180)))+radius/2+item.base.getSize().y
            {x:x, y:y}
      @base.setStyles {
        width: @size.x
        height: @size.y
      }
      @children.each (item,i) ->
        item.setStyle 'top', icpos[i].y
        item.setStyle 'left', icpos[i].x
        item.setStyle 'position', 'absolute'
}

###
---

name: Groups.Toggles

description: PushGroup element.

license: MIT-style license.

requires: 
  - Groups.Abstract
  - Interfaces.Enabled
  - Interfaces.Size

provides: Groups.Toggles
...
###
Groups.Toggles = new Class {
  Extends: Groups.Abstract
  Binds: ['change']
  Implements:[
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'toggle-group'
    }
    active: {
      setter: (value, old) ->
        if not old?
          value.set 'state', true
        else
          if old isnt value
            old.set 'state', false
          value.set 'state', true
        value
    }
  }
  update: ->
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
  change: (button,value) ->
    if button isnt @active
      if button.state
        @set 'active', button
        @fireEvent 'change', button
  emptyItems: ->
    @children.each (child) ->
      console.log child
      child.removeEvents 'invoked'
    , @
    @empty()
  removeItem: (item) ->
    if @hasChild item
      item.removeEvents 'invoked'
      @parent item
    @update()
  addItem: (item) ->
    if not @hasChild item
      item.set 'minSize', 0
      item.addEvent 'invoked', @change
      @parent item
    @update()
}

###
---

name: Groups.Lists

description: 

license: MIT-style license.

requires: 
  - Groups.Abstract
  - Interfaces.Size
  
provides: Groups.Lists

...
###
Groups.Lists = new Class {
  Extends: Groups.Abstract
  Implements: [
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'list-group'
    }
  }
  create: ->
    @parent()
    @base.setStyle 'position', 'relative'
  update: ->
    length = @children.length
    if length > 0
      cSize = @size/length
      lastSize = Math.floor(@size-(cSize*(length-1)))
      @children.each (child,i) ->
        child.setStyle 'position','absolute'
        child.setStyle 'top', 0
        child.setStyle 'left', cSize*i-1
        child.set 'size', cSize
      @children.getLast().set 'size', lastSize
    
}

###
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: 
  - Core.Abstract

provides: Data.Abstract

...
###
Data.Abstract = new Class {
  Extends: Core.Abstract
  Attributes: {
    value: {
      value: null
    }
  }
}

###
---

name: Dialog.Abstract

description: Dialog abstract base class.

license: MIT-style license.

requires: 
  - Core.Abstract
  - Buttons.Abstract

provides: Dialog.Abstract

...
###
Dialog.Abstract = new Class {
  Extends:Core.Abstract
  Implements: Interfaces.Size
  Delegates: {
    picker: ['attach', 'detach']
  }
  Attributes: {
    class: {
      value: ''
    }
    overlay: {
      value: false
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @picker = new Core.Picker()
    @overlayEl = new Core.Overlay()
  show: ->
    @picker.set 'content', @base
    @picker.show undefined, false
    if @overlay
      document.body.grab @overlayEl
  hide: (e,force)->
    if force?
      @overlayEl.base.dispose()
      @picker.hide(e,true)
    if e?
      if @base.isVisible() and not @base.hasChild(e.target) and e.target isnt @base
        @overlayEl.base.dispose()
        @picker.hide(e)
}

###
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires: 
  - Data.Abstract
  - Interfaces.Size
  
provides: Data.Text

...
###
Data.Text = new Class {
  Extends: Data.Abstract
  Implements: [
    Interfaces.Size
    Interfaces.Enabled
  ]
  Binds: ['update']  
  Attributes: {
    class: {
      value: Lattice.buildClass 'textarea'
    }
    value: {
      setter: (value) ->
        @text.set 'value', value
        value
      getter: ->
        @text.get 'value'
    }
  }
  update: ->
    @text.setStyle 'width', @size-10
  create: ->
    @text = new Element 'textarea'
    @addEvent 'enabledChange', (obj) =>
      console.log obj
      if obj.newVal
        @text.set 'disabled', false      
      else
        @text.set 'disabled', true
    @base.grab @text
    @text.addEvent 'keyup', =>
      @set 'value', @get 'value'
      @fireEvent 'change', @get 'value'
    
}

###
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract
  - Data.Text

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-prompt'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @labelDiv.replaceClass "#{value}-label", "#{old}-label"
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @labelDiv.set 'text', value
    }
    buttonLabel: {
      value: 'Ok'
      setter: (value) ->
        @button.set 'label', value
    }
  }
  update: ->
    @labelDiv.setStyle 'width', @size
    @button.set 'size', @size
    @input.set 'size', @size
    @base.setStyle 'width', 'auto'
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @input = new Data.Text()
    @button = new Buttons.Abstract()
    @base.adopt @labelDiv, @input, @button
    @button.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', @input.get('value')
      @hide(e,true)
}

###
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires:
  - Core.Picker
  - Data.Abstract
  - Dialog.Prompt
  - Interfaces.Controls
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size
  - Iterable.List

provides: Data.Select

...
###
Data.Select = new Class {
  Extends: Data.Abstract
  Implements:[
    Interfaces.Controls
    Interfaces.Children
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'select'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @text.replaceClass "#{value}-text", "#{old}-text"
        @removeIcon.set 'class', value+"-remove"
        @addIcon.set 'class', value+"-add"
        @list.set 'class', value+"-list"
        value
    }
    default: {
      value: ''
      setter: (value, old) ->
        if @text.get('text') is (old or '')
          @text.set 'text', value
        value
    }
    selected: {
      getter: ->
        @list.get 'selected'
    }
    editable: {
      value: yes
      setter: (value) ->
        if value
          @adoptChildren  @removeIcon, @addIcon
        else
          @removeChild @removeIcon
          @removeChild @addIcon
        value
    }
    value: {
      setter: (value) ->
        @list.set 'selected', @list.getItemFromLabel(value)
      getter: ->
        li = @list.get('selected')
        if li?
          li.label
    }
  }
  ready: ->
    @set 'size', @size
  create: ->
    @addEvent 'sizeChange', =>
      @list.setStyle 'width', if @size < @minSize then @minSize else @size
    
    @base.setStyle 'position', 'relative'
    @text = new Element 'div'
    @text.setStyles {
      position: 'absolute'
      top: 0
      left: 0
      right: 0
      bottom: 0
      'z-index': 0
      overflow: 'hidden'
    }
    @text.addEvent 'mousewheel', (e) =>
      e.stop()
      index = @list.items.indexOf(@list.selected)+e.wheel
      if index < 0 then index = @list.items.length-1
      if index is @list.items.length then index = 0
      @list.set 'selected', @list.items[index]

    @addIcon = new Core.Icon()
    @addIcon.base.set 'text', '+'
    @removeIcon = new Core.Icon()
    @removeIcon.base.set 'text', '-'
    $$(@addIcon.base,@removeIcon.base).setStyles {
      'z-index': '1'
      'position': 'relative'
    }
    @removeIcon.addEvent 'invoked', (el,e) =>
      e.stop()
      if @enabled
        @removeItem @list.get('selected')
        @text.set 'text', @default or ''
    @addIcon.addEvent 'invoked', (el,e) =>
      e.stop()
      if @enabled
        @prompt.show()
    
    @picker = new Core.Picker({offset:0,position:{x:'center',y:'auto'}})
    @picker.attach @base, false
    @base.addEvent 'click', (e) =>
      if @enabled
        @picker.show e
    @list = new Iterable.List({class:Lattice.buildClass 'select-list'})
    @picker.set 'content', @list
    @base.adopt @text
    
    @prompt = new Dialog.Prompt();
    @prompt.set 'label', 'Add item:'
    @prompt.attach @base, false
    @prompt.addEvent 'invoked', (value) =>
      if value
        item = new Iterable.ListItem {label:value,removeable:false,draggable:false}
        @addItem item
        @list.set 'selected', item
      @prompt.hide null, yes
    
    @list.addEvent 'selectedChange', =>
      item = @list.selected
      if item?
        @text.set 'text', item.label
        @fireEvent 'change', item.label
      else
        @text.set 'text', ''
      @picker.hide null, yes

    @update()
    
  addItem: (item) ->
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}

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

###
---

name: Data.Color

description: Color data element.

license: MIT-style license.

requires: 
  - Data.Abstract
  - Data.Number
  - Buttons.Toggle
  - Groups.Toggles
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size

provides: Data.Color

...
###
Data.Color = new Class {
  Extends:Data.Abstract
  Binds: ['update']
  Implements: [
    Interfaces.Children
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'color'
    }
    hue: {
      value: 0
      setter: (value) ->
        @hueData.set 'value', value
        value
      getter: ->
        @hueData.value
    }
    saturation: {
      value: 0
      setter: (value) ->
        @saturationData.set 'value', value
        value
      getter: ->
        @saturationData.value
    }
    lightness: {
      value: 100
      setter: (value) ->
        @lightnessData.set 'value', value
        value
      getter: ->
        @lightnessData.value
    }
    alpha: {
      value: 100
      setter: (value) ->
        @alphaData.set 'value', value
        value
      getter: ->
        @alphaData.value
    }
    type: {
      value: 'hex'
      setter: (value) ->
        @col.children.each (item) ->
          if item.label == value
            @col.set 'active', item
        , @
        value
      getter: ->
        if @col.active?
          @col.active.label
    }
    value: {
      value: new Color('#fff')
      setter: (value) ->
        console.log value.hsb[0], value.hsb[1], value.hsb[2]
        @set 'hue', value.hsb[0]
        @set 'saturation', value.hsb[1]
        @set 'lightness', value.hsb[2]
        @set 'type', value.type
        @set 'alpha', value.alpha
    }
  }
  ready: ->
    @update()
  update: ->
    hue = @get 'hue'
    saturation = @get 'saturation'
    lightness = @get 'lightness'
    type = @get 'type'
    alpha = @get 'alpha'
    if hue? and saturation? and lightness? and type? and alpha?
      ret = $HSB(hue,saturation,lightness)
      ret.setAlpha alpha
      ret.setType type
      @fireEvent 'change', new Hash(ret)
  create: ->
    @addEvent 'sizeChange', =>
      @hueData.set 'size', @size
      @saturationData.set 'size', @size
      @lightnessData.set 'size', @size
      @alphaData.set 'size', @size
      @col.set 'size', @size
    @hueData = new Data.Number {range:[0,360],reset: off, steps: 360, label:'Hue'}
    @saturationData = new Data.Number {range:[0,100],reset: off, steps: 100 , label:'Saturation'}
    @lightnessData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Value'}
    @alphaData = new Data.Number {range:[0,100],reset: off, steps: 100, label:'Alpha'}
    
    @col = new Groups.Toggles()
    ['rgb','rgba','hsl','hsla','hex'].each (item) =>
      @col.addItem new Buttons.Toggle({label:item})
    
    @hueData.addEvent 'change',  @update
    @saturationData.addEvent 'change',  @update
    @lightnessData.addEvent 'change', @update
    @alphaData.addEvent 'change',  @update
    @col.addEvent 'change',  @update
    
    
    @adoptChildren @hueData, @saturationData, @lightnessData, @alphaData, @col
}

###
---

name: Data.ColorWheel

description: ColorWheel data element. ( color picker )

license: MIT-style license.

requires: 
  - Data.Abstract
  - Data.Color
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size

provides: Data.ColorWheel

...
###
Data.ColorWheel = new Class {
  Extends: Data.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'color'
    }
    value: {
      setter: (value) ->
        @colorData.set 'value', value
    }
    wrapperClass: {
      value: 'wrapper'
      setter: (value, old) ->
        @wrapper.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
    knobClass: {
      value: 'xyknob'
      setter: (value, old) ->
        @knob.replaceClass "#{@class}-#{value}", "#{@class}-#{old}"
        value
    }
  }
   
  create: ->
    
    @hslacone = $(document.createElement('canvas'))
    @background = $(document.createElement('canvas'))
    @wrapper = new Element 'div'
   
    @knob = new Element 'div'
    @knob.setStyles {
      'position':'absolute'
      'z-index': 1
      }
      
    @colorData = new Data.Color()
    @colorData.addEvent 'change', (e) =>
      @fireEvent 'change', e
    
    @base.adopt @wrapper

    @colorData.lightnessData.addEvent 'change', (step) =>
      @hslacone.setStyle 'opacity',step/100

    @colorData.hueData.addEvent 'change', (value) =>
      @positionKnob value, @colorData.get('saturation')

    @colorData.saturationData.addEvent 'change', (value) =>
      @positionKnob @colorData.get('hue'), value
    
    @background.setStyles {
      'position': 'absolute'
      'z-index': 0
    }
    
    @hslacone.setStyles {
      'position': 'absolute'
      'z-index': 1
    }
    
    @xy = new Drag.Move @knob
    @xy.addEvent 'beforeStart', (el,e) =>
      @lastPosition = el.getPosition(@wrapper)
    @xy.addEvent 'drag', (el,e) =>
      if @enabled
        position = el.getPosition(@wrapper)
        
        x = @center.x-position.x-@knobSize.x/2
        y = @center.y-position.y-@knobSize.y/2
        
        @radius = Math.sqrt(Math.pow(x,2)+Math.pow(y,2))
        @angle = Math.atan2(y,x)
        
        if @radius > @halfWidth
          el.setStyle 'top', -Math.sin(@angle)*@halfWidth-@knobSize.y/2+@center.y
          el.setStyle 'left', -Math.cos(@angle)*@halfWidth-@knobSize.x/2+@center.x
          @saturation = 100
        else
          sat =  Math.round @radius 
          @saturation = Math.round((sat/@halfWidth)*100)
        
        an = Math.round(@angle*(180/Math.PI))
        @hue = if an < 0 then 180-Math.abs(an) else 180+an
        @colorData.set 'hue', @hue
        @colorData.set 'saturation', @saturation
      else
        el.setPosition @lastPosition
    
    @wrapper.adopt @background, @hslacone, @knob
    @addChild @colorData
  drawHSLACone: (width) ->
    ctx = @background.getContext '2d'
    ctx.fillStyle = "#000";
    ctx.beginPath();
    ctx.arc(width/2, width/2, width/2, 0, Math.PI*2, true); 
    ctx.closePath();
    ctx.fill();
    ctx = @hslacone.getContext '2d'
    ctx.translate width/2, width/2
    w2 = -width/2
    ang = width / 50
    angle = (1/ang)*Math.PI/180
    i = 0
    for i in [0..(360)*(ang)-1]
      c = $HSB(360+(i/ang),100,100)
      c1 = $HSB(360+(i/ang),0,100)
      grad = ctx.createLinearGradient(0,0,width/2,0)
      grad.addColorStop(0, c1.hex)
      grad.addColorStop(1, c.hex)
      ctx.strokeStyle = grad
      ctx.beginPath()
      ctx.moveTo(0,0)
      ctx.lineTo(width/2,0)
      ctx.stroke()
      ctx.rotate(angle)
  
  update: ->  
    @hslacone.set 'width', @size
    @hslacone.set 'height', @size
    @background.set 'width', @size
    @background.set 'height', @size
    @wrapper.setStyle 'height', @size
    if @size > 0
      @drawHSLACone @size
    @colorData.set 'size', @size
    
    @knobSize = @knob.getSize()
    @halfWidth = @size/2
    @center = {x: @halfWidth, y:@halfWidth}
    @positionKnob @colorData.get('hue'), @colorData.get('saturation')
  positionKnob: (hue,saturation) ->
    @radius = saturation/100*@halfWidth
    @angle = -((180-hue)*(Math.PI/180))
    @knob.setStyle 'top', -Math.sin(@angle)*@radius-@knobSize.y/2+@center.y
    @knob.setStyle 'left', -Math.cos(@angle)*@radius-@knobSize.x/2+@center.x
  ready: ->
    @update()
    
}

###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: 
  - Core.Abstract
...
###
Iterable.ListItem = new Class {
  Extends: Core.Abstract
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @title.set 'text', value
        value
    }
    class: {
      value: Lattice.buildClass 'list-item'
      setter: (value,old,self)->
        self::parent.call @, value, old
        @title.replaceClass "#{value}-title", "#{old}-title"
        value
    }
  }
  create: ->
    @title = new Element 'div'
    @base.grab @title
    @base.addEvent 'click', (e) =>
      @fireEvent 'select', [@,e]
    @base.addEvent 'click', =>
      @fireEvent 'invoked', @
}

###
---

name: Data.DateTime

description:  Date & Time picker elements with Core.Slot-s

license: MIT-style license.

requires: 
  - Core.Slot
  - Data.Abstract
  - Interfaces.Children
  - Interfaces.Enabled
  - Iterable.ListItem

provides: 
  - Data.DateTime
  - Data.Date
  - Data.Time

...
###
Data.DateTime = new Class {
  Extends:Data.Abstract
  Implements: [
    Interfaces.Children
    Interfaces.Enabled
    Interfaces.Size
  ]
  Attributes: {
    class: {
      value: Lattice.buildClass 'date-time'
    }
    value: {
      value: new Date()
      setter: (value) ->
        @value = value
        @updateSlots()
        value
    }
    time: {
      readonly: yes
      value: yes
    }
    date: {
      readonly: yes
      value: yes
    }
  }
  create: ->
    @yearFrom = 1950
    if @get('date')
      @days = new Core.Slot()
      @month = new Core.Slot()
      @years = new Core.Slot()
    if @get('time')
      @hours = new Core.Slot()
      @minutes = new Core.Slot()
    @populate()
    if @get('time')
      @hours.addEvent 'change', (item) =>
        @value.set 'hours', item.value
        @update()
      @minutes.addEvent 'change', (item) =>
        @value.set 'minutes', item.value
        @update()
    if @get('date')
      @years.addEvent 'change', (item) =>
        @value.set 'year', item.value
        @update()
      @month.addEvent 'change', (item) =>
        @value.set 'month', item.value
        @update()
      @days.addEvent 'change', (item) =>
        @value.set 'date', item.value
        @update()
    @
  populate: ->
    if @get('time')
      i = 0
      while i < 24
        item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
        item.value = i
        @hours.addItem item
        i++
      i = 0
      while i < 60
        item = new Iterable.ListItem {label: (if i<10 then '0'+i else i),removeable:false}
        item.value = i
        @minutes.addItem item
        i++
    if @get('date')
      i = 0
      while i < 30
        item = new Iterable.ListItem {label:(if i<10 then '0'+i else i),removeable:false}
        item.value = i+1
        @days.addItem item
        i++
      i = 0
      while i < 12
        item = new Iterable.ListItem {label:(if i<10 then '0'+i else i),removeable:false}
        item.value = i
        @month.addItem item
        i++
      i = @yearFrom
      while i <= new Date().get 'year'
        item = new Iterable.ListItem {label:i,removeable:false}
        item.value = i
        @years.addItem item
        i++
  update: ->
    @fireEvent 'change', @value
    buttonwidth = Math.floor(@size / @children.length)
    @children.each (btn) ->
      btn.set 'size', buttonwidth
    if last = @children.getLast()
      last.set 'size', @size-buttonwidth*(@children.length-1)
    @updateSlots()
  ready: ->
    if @get('date')
      @adoptChildren @years, @month, @days
    if @get('time')
      @adoptChildren @hours, @minutes
    @update()
  updateSlots: ->
    if @get('date') and @value
      cdays = @value.get 'lastdayofmonth'
      listlength = @days.list.children.length
      if cdays > listlength
        i = listlength+1
        while i <= cdays
          item=new Iterable.ListItem {label:i}
          item.value = i
          @days.addItem item
          i++
      else if cdays < listlength
        i = listlength
        while i > cdays
          @days.list.removeItem @days.list.children[i-1]
          i--
      @days.list.set 'selected', @days.list.children[@value.get('date')-1]
      @month.list.set 'selected', @month.list.children[@value.get('month')]
      @years.list.set 'selected', @years.list.getItemFromLabel(@value.get('year'))
    if @get('time') and @value
      @hours.list.set 'selected', @hours.list.children[@value.get('hours')]
      @minutes.list.set 'selected', @minutes.list.children[@value.get('minutes')]
}
Data.Time = new Class {
  Extends:Data.DateTime
  Attributes: {
    class: {
      value: Lattice.buildClass 'time'
    }
    date: {
      value: no
    }
  }
}
Data.Date = new Class {
  Extends:Data.DateTime
  Attributes: {
    class: {
      value: Lattice.buildClass 'date'
    }
    time: {
      value: no
    }
  }
}

###
---

name: Data.Table

description: Text data element.

requires: 
  - Data.Abstract

provides: Data.Table

...
###
Data.Table = new Class {
  Extends: Data.Abstract
  Binds: ['update']
  Attributes: {
    class: {
      value: Lattice.buildClass 'table'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @hremove.set 'class', value+"-remove"
        @hadd.set 'class', value+"-add"
        @vremove.set 'class', value+"-remove"
        @vadd.set 'class', value+"-add"
        value
    }
    value: {
      setter: (value) ->
        @base.empty()
        value.each (it) -> 
          tr = new Element('tr')
          @base.grab tr
          it.each (v) ->
            tr.grab new Element('td',{text:v})
          , @
        , @
        @fireEvent 'change', @get 'value'
        value
      getter: ->
        ret = []
        for tr in @base.children
          tra = []
          for td in tr.children
            tra.push td.get 'text'
          ret.push tra
        ret
    }
  }
  create: ->
    @loc = {h:0,v:0}
    delete @base
    @base = new Element 'table'
    @base.grab new Element('tr').grab(new Element 'td')
    @columns = 5
    @rows = 1
    @input = new Element 'input'
    @setupIcons()
    @setupEvents()
    
  setupEvents: ->
    @hadd.addEvent 'invoked', @addColumn.bind @
    @hremove.addEvent 'invoked', @removeColumn.bind @
    @vadd.addEvent 'invoked', @addRow.bind @
    @vremove.addEvent 'invoked', @removeRow.bind @
    
    @icg1.base.addEvent 'mouseenter', @suspendIcons.bind @
    @icg1.base.addEvent 'mouseleave', @hideIcons.bind @
    @icg2.base.addEvent 'mouseenter', @suspendIcons.bind @
    @icg2.base.addEvent 'mouseleave', @hideIcons.bind @ 
    
    @base.addEvent 'mouseleave', (e) => 
      @id1 = @icg1.hide.delay(400,@icg1)
      @id2 = @icg2.hide.delay(400,@icg2)
    @base.addEvent 'mouseenter', (e) =>
      @suspendIcons()
      @icg1.show()
      @icg2.show()
    @base.addEvent 'mouseenter:relay(td)', (e) => 
      @positionIcons e.target
    @input.addEvent 'blur', =>
      @input.dispose()
      @editTarget.set 'text', @input.get 'value'
      @fireEvent 'change', @get 'value'
    @base.addEvent 'click:relay(td)', (e) =>
      if @input.isVisible()
        @input.dispose()
        @editTarget.set 'text', @input.get 'value'
      @input.set 'value', e.target.get 'text'
      size = e.target.getSize()
      @input.setStyles {
        width: size.x
        height: size.y
      }
      @editTarget = e.target
      e.target.set 'text', ''
      e.target.grab @input
      @input.focus()
      
  positionIcons: (target) ->
    pos = target.getPosition()
    pos1 = @base.getPosition()
    size = @icg1.base.getSize()
    size2 = @base.getSize()
    @icg1.setStyle 'left', pos.x
    @icg1.setStyle 'top', pos1.y-size.y
    @icg2.setStyle 'top', pos.y
    @icg2.setStyle 'left', pos1.x+size2.x
    @loc = @getLocation target
    @target = target
    @vremove.set 'enabled', @base.children.length > 1
    @hremove.set 'enabled', @base.children[0].children.length > 1
    
  setupIcons: ->
    @icg1 = new Groups.Icons()
    @icg2 = new Groups.Icons()
    
    @hadd = new Core.Icon()
    @hremove = new Core.Icon()
    @vadd = new Core.Icon()
    @vremove = new Core.Icon()
    
    @hadd.base.set 'text', '+'
    @hremove.base.set 'text', '-'
    @vadd.base.set 'text', '+'
    @vremove.base.set 'text', '-'
    
    @icg1.addItem @hadd
    @icg1.addItem @hremove
    @icg2.addItem @vadd
    @icg2.addItem @vremove
    
    @icg1.setStyle 'position', 'absolute'
    @icg2.setStyle 'position', 'absolute'
    
    document.body.adopt @icg1, @icg2
    @hideIcons()
    
  suspendIcons: ->
    if @id1?
      clearTimeout @id1
      @id1 = null
    if @id2?
      clearTimeout @id2
      @id2 = null
  hideIcons: ->
    @icg1.hide()
    @icg2.hide()
    
  getLocation: (td) ->
    ret = {h:0,v:0}
    tr = td.getParent('tr')
    children = tr.getChildren()
    for i in [0..children.length]
      if td is children[i]
        ret.h = i
    children = @base.getChildren()
    for i in [0..children.length]
      if tr is children[i]
        ret.v = i
    ret
      
  testHorizontal: (where) ->
    if (w = Number.from(where))?
      if w < @base.children[0].children.length and w > 0
        @loc.h = w-1    

  testVertical: (where) ->
    if (w = Number.from(where))?
      if w < @base.children.length and w > 0
        @loc.v = w-1

  addRow: (where) ->
    @testVertical where
    tr = new Element 'tr'
    baseChildren = @base.children
    trchildren = baseChildren[0].children
    if baseChildren.length > 0
      baseChildren[@loc.v].grab tr, 'before'
    else
      @base.grab tr
    for i in [1..trchildren.length]
      tr.grab new Element 'td'
    @positionIcons @base.children[@loc.v].children[@loc.h]
    @fireEvent 'change', @get 'value'
    
  addColumn: (where) ->
    @testHorizontal where
    for tr in @base.children
      tr.children[@loc.h].grab new Element('td'), 'before'
    @positionIcons @base.children[@loc.v].children[@loc.h]
    @fireEvent 'change', @get 'value'
    
  removeRow: (where) ->
    @testVertical where
    if @base.children.length isnt 1
      @base.children[@loc.v].destroy()
      if @base.children[@loc.v]?
        @positionIcons @base.children[@loc.v].children[@loc.h]
      else
        @positionIcons @base.children[@loc.v-1].children[@loc.h]
    @fireEvent 'change', @get 'value'
  
  removeColumn: (where) ->
    @testHorizontal where
    if @base.children[0].children.length isnt 1
      for tr in @base.children
        tr.children[@loc.h].destroy()
      if @base.children[@loc.v].children[@loc.h]?
        @positionIcons @base.children[@loc.v].children[@loc.h]
      else
        @positionIcons @base.children[@loc.v].children[@loc.h-1]
    @fireEvent 'change', @get 'value'
      
}

###
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires: 
  - Data.Abstract
  - Data.Number
  - Data.Select 
  - Interfaces.Children
  - Interfaces.Enabled
  - Interfaces.Size

provides: Data.Unit

...
###
UnitList = {
  px: "px"
  '%': "%"
  em: "em"
  ex:"ex"
  gd:"gd"
  rem:"rem"
  vw:"vw"
  vh:"vh"
  vm:"vm"
  ch:"ch"
  "in":"in"
  mm:"mm"
  pt:"pt"
  pc:"pc"
  cm:"cm"
  deg:"deg"
  grad:"grad"
  rad:"rad"
  turn:"turn"
  s:"s"
  ms:"ms"
  Hz:"Hz"
  kHz:"kHz"
  }
Data.Unit = new Class {
  Extends:Data.Abstract
  Implements: [
    Interfaces.Children 
    Interfaces.Enabled
    Interfaces.Size
  ]
  Binds: ['update']
  Attributes: {
    class: {
      value: Lattice.buildClass 'unit'
    }
    value: {
      setter: (value) ->
        if typeof value is 'string'
          match = value.match(/(-?\d*)(.*)/)
          value = match[1]
          unit = match[2]
          @sel.set 'value', unit
          @number.set 'value', value
      getter: ->
        String.from @number.value+@sel.value
    }
  }
  update: ->
    @fireEvent 'change', String.from @number.value+@sel.get('value')
  create: ->
    @addEvent 'sizeChange', =>
      @number.set 'size', @size-@sel.get('size')
    @number = new Data.Number {range:[-50,50],reset: on, steps: [100]}
    @sel = new Data.Select({size: 80})
    Object.each UnitList, (item) =>
      @sel.addItem new Iterable.ListItem({label:item,removeable:false,draggable:false})
    @sel.set 'value', 'px'

    @number.addEvent 'change', @update
    @sel.addEvent 'change',@update
    @adoptChildren @number, @sel
  ready: ->
    @set 'size', @size
}
    

###
---

name: Dialog.Alert

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Alert

...
###
Dialog.Alert = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-alert'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @labelDiv.replaceClass "#{value}-label", "#{old}-label"
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @labelDiv.set 'text', value
    }
    buttonLabel: {
      value: 'Ok'
      setter: (value) ->
        @button.set 'label', value
    }
  }
  update: ->
    @labelDiv.setStyle 'width', @size
    @button.set 'size', @size
    @base.setStyle 'width', 'auto'
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @button = new Buttons.Abstract()
    @base.adopt @labelDiv, @button
    @button.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', [@,e]
      @hide(e,true)
}

###
---

name: Dialog.Confirm

description: Select Element

license: MIT-style license.

requires: 
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Confirm

...
###
Dialog.Confirm = new Class {
  Extends: Dialog.Abstract
  Attributes: {
    class: {
      value: Lattice.buildClass 'dialog-confirm'
      setter: (value, old, self) ->
        self::parent.call @, value, old
        @labelDiv.replaceClass "#{value}-label", "#{old}-label"
        value
    }
    label: {
      value: ''
      setter: (value) ->
        @labelDiv.set 'text', value
    }
    okLabel: {
      value: 'Ok'
      setter: (value) ->
        @okButton.set 'label', value
    }
    cancelLabel: {
      value: 'Cancel'
      setter: (value) ->
        @cancelButton.set 'label', value
    }
  }
  update: ->
    @labelDiv.setStyle 'width', @size
    @okButton.set 'size', @size/2
    @cancelButton.set 'size', @size/2
    oksize = @okButton.getSize().x
    cancelsize = @cancelButton.getSize().x
    @base.setStyle 'width', oksize+cancelsize
  create: ->
    @parent()
    @labelDiv = new Element 'div'
    @okButton = new Buttons.Abstract()
    @cancelButton = new Buttons.Abstract()
    $$(@okButton.base, @cancelButton.base).setStyle 'float', 'left'
    @base.adopt @labelDiv, @okButton, @cancelButton, new Element('div',{style:"clear: both"})
    @okButton.addEvent 'invoked', (el,e) =>
      @fireEvent 'invoked', [@,e]
      @hide(e,true)
    @cancelButton.addEvent 'invoked', (el,e) =>
      @fireEvent 'cancelled', [@,e]
      @hide(e,true)
}

###
---

name: Iterable.MenuListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.MenuListItem

requires: 
  - Iterable.ListItem
...
###
Iterable.MenuListItem = new Class {
  Extends: Iterable.ListItem
  Attributes: {
    icon: {
      setter: (value) ->
        @iconEl.set 'image', value
    }
    shortcut: {
      setter: (value) ->
        @sc.set 'text', value.toUpperCase()
        value
    }
    class: {
      value: Lattice.buildClass 'menu-list-item'
    }
  }
  create: ->
    @parent()
    @iconEl = new Core.Icon({class:@get('class')+'-icon'})
    @sc = new Element 'div'
    @sc.setStyle 'float', 'right'
    @title.setStyle 'float', 'left'
    @iconEl.setStyle 'float', 'left'
    @base.grab @iconEl, 'top'
    @base.grab @sc
}

###
---

name: Blender

description: Blender Layout Engine for G.UI

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - Core.Button
  - Iterable.ListItem

provides: Blender

...
###
Blender = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-layout'
    }
    active: {
      value: null
      setter: (newv,oldv)->
        if oldv?
          oldv.base.removeClass 'bv-selected'
          oldv.base.setStyle 'border', ''
        newv.base.addClass 'bv-selected'
        newv.base.setStyle 'border', '1px solid #888'
        newv
    }
  }
  toggleFullScreen: (view) ->
    @emptyNeigbours()
    if !view.fullscreen 
      view.lastPosition = {
        top: view.get 'top'
        bottom: view.get 'bottom'
        left: view.get 'left'
        right: view.get 'right'
      }
      view.set 'top', 0
      view.set 'bottom', '100%'
      view.set 'left', 0
      view.set 'right', '100%'
      view.fullscreen = true
      view.base.setStyle 'z-index',100
    else
      view.fullscreen = false
      view.base.setStyle 'z-index',1
      view.set 'top', view.lastPosition.top
      view.set 'bottom', view.lastPosition.bottom
      view.set 'left', view.lastPosition.left
      view.set 'right', view.lastPosition.right
    @calculateNeigbours()
  splitView: (view,mode)->
    @emptyNeigbours()
    view2 = new Blender.View()
    if mode is 'vertical'
      if view.restrains.bottom
        view.restrains.bottom = no
        view2.restrains.bottom = yes
      top = view.get('top')
      bottom = view.get('bottom')
      view2.set 'top', Math.floor(top+((bottom-top)/2))
      view2.set 'bottom', bottom
      view2.set 'left', view.get('left')
      view2.set 'right', view.get('right')
      view.set 'bottom', Math.floor(top+((bottom-top)/2))
      
    if mode is 'horizontal'
      if view.restrains.right
        view.restrains.right = no
        view2.restrains.right = yes
      left =  view.get('left')
      right = view.get('right')
      view2.set 'top', view.get('top')
      view2.set 'bottom', view.get('bottom')
      view2.set 'left', Math.floor(left+((right-left)/2))
      view2.set 'right', right
      view.set 'right', Math.floor(left+((right-left)/2))
    @addView view2
    @calculateNeigbours()
    @updateToolBars()
    
  deleteView: (view)->
    @emptyNeigbours()
    n = @getFullNeigbour(view)
    if n?
      n.view.set n.side, view.get n.side
      @removeChild @active
      @set 'active', n.view
    @calculateNeigbours()
  getFullNeigbour: (view) ->
    ret = {
      side: null
      view: null
    }
    if ret.view = @getNeigbour(view,'left')
      ret.side = 'right'
      return ret
    if ret.view = @getNeigbour(view,'right')
      ret.side = 'left'
      return ret
    if ret.view = @getNeigbour(view,'top')
      ret.side = 'bottom'
      return ret
    if ret.view = @getNeigbour(view,'bottom')
      ret.side = 'top'
      return ret  
  getNeigbour: (view,prop) ->
    mod = prop
    switch mod
      when 'right'
        opp = 'left'
        third = 'height'
      when 'left'
        third = 'height'
        opp = 'right'
      when 'top'
        third = 'width'
        opp = 'bottom'
      when 'bottom'
        third = 'width'
        opp = 'top'
    ret = null
    val = view.get mod
    val1 = view.get third
    @children.each (it) ->
      if it isnt view
        w = it.get third
        v = it.get opp
        if v.inRange(val,3) and w.inRange(val1,3)
          ret = it
    ret 
  getSimilar: (item,prop)->  
    mod = prop
    switch mod
      when 'right'
        opp = 'left'
      when 'left'
        opp = 'right'
      when 'top'
        opp = 'bottom'
      when 'bottom'
        opp = 'top'
    ret = {
      mod: []
      opp: []
    }
    val = item.get mod
    @children.each (it) ->
      if it isnt item
        v = it.get opp
        if v.inRange(val,5)
          ret.opp.push it
        v = it.get mod
        if v.inRange(val,5)
          ret.mod.push it
    ret 
  update: (e) ->
    @emptyNeigbours()
    @children.each (child)->
      child.resize()
      child.update()
    @calculateNeigbours()
  fromObj: (obj) ->
    @emptyNeigbours()
    for view in obj
      @addView new Blender.View(view)
    @calculateNeigbours()
  create: ->
    @i = 0
    @stack = {}
    @hooks = []
    @views = []
    window.addEvent 'keydown', ((e)->
      if e.key is 'up' and e.control
        @toggleFullScreen @get 'active'
      if e.key is 'delete' and e.control
        @deleteView @active
    ).bind @
    window.addEvent 'resize', @update.bind @
    #@addView new Blender.View({top:0,left:0,right:"100%",bottom:"100%"
    #  ,restrains: {top:yes,left:yes,right:yes,bottom:yes}
    #})
    console.log 'Blender Layout engine!'
  emptyNeigbours: ->
    @children.each ((child)->
      child.hooks.right = {}
      child.hooks.top = {}
      child.hooks.bottom = {}
      child.hooks.left = {}
    ).bind @
  calculateNeigbours: ->
    @children.each ((child)->
      child.hooks.right = @getSimilar(child,'right')
      child.hooks.top = @getSimilar(child,'top')
      child.hooks.bottom = @getSimilar(child,'bottom')
      child.hooks.left = @getSimilar(child,'left')
    ).bind @
  removeView: (view) ->
    view.removeEvents 'split'
    @removeChild view
  addView: (view) ->
    @addChild view
    @updateToolBar view
    view.base.addEvent 'click',( ->
      @set 'active', view
    ).bind @
    view.addEvent 'split', @splitView.bind @
    view.addEvent 'content-change', ((e)->
      if e?
        @setViewContent e, view
    ).bind @
    if view.stack?
      view.toolbar.select.list.items.each (item) ->
        if item.label is view.stack
          @set 'selected', item
      , view.toolbar.select.list
  setViewContent: (viewContent,view) ->
    if not @stack[viewContent].unique
      content = new @stack[viewContent].class()
    else
      if @stack[viewContent].content?
        content = @stack[viewContent].content
        @stack[viewContent].owner.set 'content', null
        @stack[viewContent].owner.toolbar.select.list.set 'selected', null
      else
        content = @stack[viewContent].content = new @stack[viewContent].class()
      @stack[viewContent].owner = view
    view.set 'content', content
  addToStack: (name,viewContent, unique) ->
    @stack[name] = {class: viewContent, unique: unique}
    @updateToolBars()
  updateToolBar: (view) ->
    view.toolbar.select.list.removeAll()
    Object.each @stack, (value,key)->
       @addItem new Iterable.BlenderListItem({label:key,removeable:false,draggable:false})
    , view.toolbar.select
  updateToolBars: ->
    @children.each (child)->
      @updateToolBar child
    , @
}

###
---

name: Blender.Corner

description: Viewport

license: MIT-style license.

requires: 
  - Core.Icon

provides: Blender.Corner

...
###
Blender.Corner = new Class {
  Extends: Core.Icon
  Attributes: {
    snapDistance: {
      value: 0
    }
  }
  create: ->
    @drag = new Drag @base, {style:false}
    @drag.addEvent 'start',((el,e) ->
      @startPosition = e.page
      @direction = null
    ).bind @
    @drag.addEvent 'drag', ((el,e) ->
      directions = []
      offsets = []
      if @startPosition.x < e.page.x 
        directions.push 'right'
        offsets.push e.page.x - @startPosition.x
      if @startPosition.x > e.page.x 
        directions.push 'left'
        offsets.push @startPosition.x - e.page.x
      if @startPosition.y < e.page.y
        directions.push 'bottom'
        offsets.push e.page.y - @startPosition.y
      if @startPosition.y > e.page.y 
        directions.push 'top'
        offsets.push @startPosition.y - e.page.y
      maxdir = directions[offsets.indexOf(offsets.max())]
      maxoffset = offsets.max()
      if maxoffset > @snapDistance
        if @direction isnt maxdir
          @direction = maxdir
          @fireEvent 'directionChange', [maxdir, e]
          @drag.stop()
    ).bind @
    @parent()
}

###
---

name: Blender.Toolbar

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - Data.Select

provides: Blender.Toolbar

...
###
Interfaces.HorizontalChildren = new Class {
  Extends: Interfaces.Children
  addChild: (el, where) ->
    @children.push el
    document.id(el).setStyle 'float', 'left'
    @base.grab el, where
}
Blender.Toolbar = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.HorizontalChildren
  Attributes: {
    class: {
      value: 'blender-toolbar'
    }
    content: {
      value: null
      setter: (newVal,oldVal)->
        @removeChild oldVal
        @addChild newVal, 'top'
        newVal
    }
  }
  create: ->
    @select = new Data.Select({editable:false,size:80});
    @addChild @select
}

###
---

name: Blender.View

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - Core.Scrollbar
  - Blender.Corner
  - Blender.Toolbar

provides: Blender.View

...
###
Blender.View = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-view'
    }
    top: {
      setter: (value) ->
        value = Number.eval value, window.getSize().y
        @base.setStyle 'top', value+1
        value
    }
    width: {
      getter: ->
        @get('right')-@get('left')
    }
    height: {
      getter: ->
        @get('bottom')-@get('top')
    }
    left: {
      setter: (value) ->
        value = Number.eval value, window.getSize().x
        @base.setStyle 'left', value
        value
    }
    right: {
      setter: (value) ->
        value = Number.eval value, window.getSize().x
        @base.setStyle 'right',  window.getSize().x-value+1
        value
    }
    bottom: {
      setter: (value) ->
        value = Number.eval value, window.getSize().y
        @base.setStyle 'bottom', window.getSize().y-value
        value
    }
    content: {
      value: null
      setter: (newVal,oldVal)->
        if oldVal
          @removeChild oldVal
          if oldVal.toolbar?
            @toolbar.removeChild oldVal.toolbar
        delete oldVal
        if newVal?
          if newVal.base?
            newVal.base.setStyle 'position', 'relative'
          @addChild newVal, 'top'
          if newVal.toolbar?
            @toolbar.addChild newVal.toolbar
        newVal
    }
    stack: {
      setter: (value) ->
        @fireEvent 'content-change', value
        value
    }
  }
  resize: ->
    winsize = window.getSize()
    horizpercent = winsize.x/@windowSize.x
    vertpercent = winsize.y/@windowSize.y
    @windowSize = winsize
    @set 'right', Math.floor @right*horizpercent
    @set 'left', Math.floor @left*horizpercent
    @set 'top', Math.floor @top*vertpercent
    @set 'bottom', Math.floor @bottom*vertpercent
  update: ->
    width = @base.getSize().x-30
    @children.each ((child) ->
      child.set 'size', width
    ).bind @
    @slider.set 'size', @base.getSize().y-60
    if @base.getSize().y < @base.getScrollSize().y
      @slider.show()
    else
      @slider.hide()
  updateScrollTop: ->
    @content.base.setStyle 'top', ((@base.getSize().y-@content.base.getSize().y-30)/100)*@slider.get('value')
  create: ->
    @windowSize = window.getSize()
    @addEvent 'rightChange', (o)->
      a = @hooks.right
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'right', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'left', o.newVal
    @addEvent 'topChange', (o)->
      a = @hooks.top
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'top', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'bottom', o.newVal
    @addEvent 'bottomChange', (o)->
      a = @hooks.bottom
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'bottom', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'top', o.newVal
    @addEvent 'leftChange', (o)->
      a = @hooks.left
      if a?
        if a.mod?
          a.mod.each (item) ->
            item.set 'left', o.newVal
        if a.opp?
          a.opp.each (item) ->
            item.set 'right', o.newVal
    @hooks = {}
    @slider = new Core.Srcollbar({steps:100,mode:'vertical'})
    @slider.minSize = 0
    @slider.base.setStyle 'min-height', 0
    
    @slider.addEvent 'step', @updateScrollTop.bind @
      
    
    @toolbar = new Blender.Toolbar()
    @toolbar.select.addEvent 'change', ((e)->
      @fireEvent 'content-change', e
    ).bind @
    @base.adopt @slider, @toolbar

    @position = {x:0,y:0}
    @size = {w:0,h:0}
    @topLeftCorner = new Blender.Corner({class:'topleft'})
    @topLeftCorner.addEvent 'directionChange',((dir,e) ->
      e.stop()
      if e.control
        if (dir is 'left' or dir is 'right') 
          @fireEvent 'split',[@,'horizontal']
        if (dir is 'bottom' or dir is 'top')
          @fireEvent 'split',[@,'vertical']
      else
        if (dir is 'bottom' or dir is 'top') and @get('top') isnt 0
          @drag.startpos = {y:Number.from(@base.getStyle('top'))}
          @drag.options.modifiers = {x:null,y:'top'}
          @drag.options.invert = true
          @drag.start(e)
        
        if (dir is 'left' or dir is 'right') and @get('right') isnt window.getSize().x
          @drag.startpos = {x:Number.from(@get('right'))}
          @drag.options.modifiers = {x:'right',y:null}
          @drag.options.invert = true
          @drag.start(e)
    ).bind @
    @bottomRightCorner = new Blender.Corner({class:'bottomleft'})
    @bottomRightCorner.addEvent 'directionChange',((dir,e) ->
      if (dir is 'bottom' or dir is 'top') and  @get('bottom') isnt window.getSize().y
        @drag.startpos = {y:Number.from(@get('bottom'))}
        @drag.options.modifiers = {x:null,y:'bottom'}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'left' or dir is 'right') and  @get('left') isnt 0
        @drag.startpos = {x:Number.from(@base.getStyle('left'))}
        @drag.options.modifiers = {x:'left',y:null}
        @drag.options.invert = true
        @drag.start(e)
    ).bind @
    @adoptChildren @topLeftCorner, @bottomRightCorner
    @drag = new Drag @base, {modifiers:{x:'',y:''}, style:false}
    @drag.detach()
    @drag.addEvent 'drag', ((el,e) ->
      if @drag.options.modifiers.x?
        offset = @drag.mouse.start.x-@drag.mouse.now.x
        if @drag.options.invert
          offset = -offset
        posx = offset+@drag.startpos.x
        @set @drag.options.modifiers.x, if posx > 0 then posx else 0
      if @drag.options.modifiers.y?
        offset = @drag.mouse.start.y-@drag.mouse.now.y
        if @drag.options.invert
          offset = -offset
        posy = offset+@drag.startpos.y
        @set @drag.options.modifiers.y, if posy > 0 then posy else 0
    ).bind @
  check: ->
}

###
---

name: Pickers

description: Pickers for Data classes.

license: MIT-style license.

requires: 
  - Core.Picker
  - Data.Color
  - Data.Number
  - Data.Text
  - Data.Date
  - Data.Time
  - Data.DateTime

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text, Pickers.Time, Pickers.Date, Pickers.DateTime ] 

...
###
Pickers.Base = new Class {
  Extends: Core.Picker
  Delegates:{
    data: ['set']
  }
  Attributes: {
    type: {
      value: null
    }
  }
  show: (e,auto) ->
    if @data is undefined
      @data = new Data[@type]()
      @set 'content', @data
    @parent e, auto
}
Pickers.Color = new Pickers.Base {type:'ColorWheel'}
Pickers.Number = new Pickers.Base {type:'Number'}
Pickers.Time = new Pickers.Base {type:'Time'}
Pickers.Text = new Pickers.Base {type:'Text'}
Pickers.Date = new Pickers.Base {type:'Date'}
Pickers.DateTime = new Pickers.Base {type:'DateTime'}
Pickers.Table = new Pickers.Base {type:'Table'}
Pickers.Unit = new Pickers.Base {type:'Unit'}
Pickers.Select = new Pickers.Base {type:'Select'}
Pickers.List = new Pickers.Base {type:'List'}

