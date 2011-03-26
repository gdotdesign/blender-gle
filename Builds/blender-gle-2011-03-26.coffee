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
  - Class.Delegates
  - Class.Attributes
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

Class.Mutators.Attributes = (attributes) ->
    $setter = attributes.$setter
    $getter = attributes.$getter
    
    if @::$attributes
      attributes = Object.merge @::$attributes, attributes

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
                newVal = attr.setter.attempt [value, oldVal], @
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
  Color.implement {
    type: 'hex'
    alpha: ''
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
          String.from "hsl(#{@hsl[0]}, #{@hsl[1]}%, #{@hsl[2]}%)"
        when "hsla"
          @hsl = @hsvToHsl()
          String.from "hsla(#{@hsl[0]}, #{@hsl[1]}%, #{@hsl[2]}%, #{@alpha/100})"
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
    oldGrab: Element::grab
    oldInject: Element::inject
    oldAdopt: Element::adopt
    oldPosition: Element::position
    position: (options) ->
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
      console.log options.position             
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
       console.log ofa
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

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

requires: [Class.Delegates, Element.Extras]

...
###
Interfaces = {}
Layout = {}
Core = {}
Data = {}
Iterable = {}
Pickers = {}
Forms = {}
Dialog = {}

if !GDotUI?
  GDotUI = {}

GDotUI.Config ={
    tipZindex: 100
    floatZindex: 0
    cookieDuration: 7*1000
}


###
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

requires: 
  - GDotUI

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
  - Class.Attributes
  - Element.Extras
  - GDotUI
  - Interfaces.Mux

provides: Core.Abstract

...
###

#INK save nodedata to html file in a comment.
# move this somewhere else
getCSS = (selector, property) ->
  #selector = "/\\.#{@get('class')}$/"
  ret = null
  checkStyleSheet = (stylesheet) ->
    try
      if stylesheet.cssRules?
        $A(stylesheet.cssRules).each (rule) ->
          if rule.styleSheet?
            checkStyleSheet(rule.styleSheet)
          if rule.selectorText?
            if rule.selectorText.test(eval(selector))
              ret = rule.style.getPropertyValue(property)
    catch error
      console.log error
  $A(document.styleSheets).each (stylesheet) ->
    checkStyleSheet(stylesheet)
  ret

Core.Abstract = new Class {
  Implements:[Events
              Interfaces.Mux]
  Attributes: {
    class: {
      setter: (value, old) ->
        value = String.from value
        @base.removeClass old
        @base.addClass value
        value
    }
  }
  initialize: (options) ->
    @base = new Element 'div'
    @base.addEvent 'addedToDom', @ready.bind @
    @mux()
    @create()
    @setAttributes options
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

name: Interfaces.Children

description: 

license: MIT-style license.

requires: 
  - GDotUI

provides: Interfaces.Children

...
###
Interfaces.Children = new Class {
  _$Children: ->
    @children = []
  hasChild: (child) ->
    if @children.indexOf child is -1 then no else yes
  adoptChildren: ->
    children = Array.from arguments 
    @children.append children
    @base.adopt arguments
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
      @removeChild child
    , @
}


###
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

requires: 
  - GDotUI
...
###
Interfaces.Enabled = new Class {
  _$Enabled: ->
    @enabled = on
  supress: ->
    if @children?
      @children.each (item) ->
        if item.disable?
          item.supress()
    @base.addClass 'supressed'
    @enabled = off
  unsupress: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.unsupress()
    @base.removeClass 'supressed'
    @enabled = on
  enable: ->
    if @children?
      @children.each (item) ->
        if item.enable?
          item.unsupress()
    @enabled = on
    @base.removeClass 'disabled'
    @fireEvent 'enabled'
  disable: ->
    if @children?
      @children.each (item) ->
        if item.disable?
          item.supress()
    @enabled = off
    @base.addClass 'disabled'
    @fireEvent 'disabled'
}


###
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Controls

requires: 
  - GDotUI
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

name: Interfaces.Size

description: Size minsize from css....

license: MIT-style license.

provides: Interfaces.Size

requires: [GDotUI]
...
###
Interfaces.Size = new Class {
  _$Size: ->
    @size = Number.from getCSS("/\\.#{@get('class')}$/",'width')
    @minSize = Number.from(getCSS("/\\.#{@get('class')}$/",'min-width')) or 0
    @addAttribute 'minSize', {
      value: null
      setter: (value,old) ->
        @base.setStyle 'min-width', value
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

name: Core.Button

description: Basic button element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls
  - Interfaces.Enabled
  - Interfaces.Size

provides: Core.Button

...
###
Core.Button = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
    Interfaces.Size
  ]
  Attributes: {
    label: {
      value: GDotUI.Theme.Button.label
      setter: (value) ->
        @base.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.Button.class
    }
  }
  create: ->
    @base.addEvent 'click', ((e)->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bind @
}


###
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements it.

license: MIT-style license.

provides: [Interfaces.Draggable, Drag.Float, Drag.Ghost]

requires: [GDotUI]
...
###
Drag.Float = new Class {
	Extends: Drag.Move
	initialize: (el,options) ->
		@parent el, options
	start: (event) ->
		if @options.target == event.target
			@parent event
}
Drag.Ghost = new Class {
	Extends: Drag.Move
	options: {
	  opacity: 0.65
		pos: false
		remove: ''}
	start: (event) ->
		if not event.rightClick
			@droppables = $$(@options.droppables)
			@ghost()
			@parent(event)
	cancel: (event) ->
		if event
			@deghost()
		@parent(event)
	stop: (event) ->
		@deghost()
		@parent(event)
	ghost: ->
		@element = (@element.clone()
		).setStyles({
			'opacity': @options.opacity,
			'position': 'absolute',
			'z-index': 5003,
			'top': @element.getCoordinates()['top'],
			'left': @element.getCoordinates()['left']
			'-webkit-transition-duration': '0s'
		}).inject(document.body).store('parent', @element)
		@element.getElements(@options.remove).dispose()	
	deghost: ->
		e = @element.retrieve 'parent'
		newpos = @element.getPosition e.getParent()
		if @options.pos && @overed==null
			e.setStyles({
			'top': newpos.y,
			'left': newpos.x
			})
		@element.destroy();
		@element = e;
}
Interfaces.Draggable = new Class {
	Implements: Options
	options:{
		draggable: off
		ghost: off
		removeClasses: ''
	}
	_$Draggable: ->
		if @options.draggable
			if @handle == null
				@handle = @base
			if @options.ghost
				@drag = new Drag.Ghost @base, {target:@handle, handle:@handle, remove:@options.removeClasses, droppables: @options.droppables, precalculate: on, pos:true}
			else
				@drag = new Drag.Float @base, {target:@handle, handle:@handle}
			@drag.addEvent 'drop', (->
				@fireEvent 'dropped', arguments
			).bindWithEvent @
}


###
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: [GDotUI, Interfaces.Draggable]
...
###
Iterable.ListItem = new Class {
  Extends:Core.Abstract
  Implements: [Interfaces.Draggable
               Interfaces.Enabled ]
  Attributes: {
    label: {
      value: ''
      setter: (value) ->
        @title.set 'text', value
        value
    }
    class: {
      value: GDotUI.Theme.ListItem.class
    }
  }
  options:{
    classes:{
      title: GDotUI.Theme.ListItem.title
      subtitle: GDotUI.Theme.ListItem.subTitle
    }
    title:''
    subtitle:''
    draggable: off
    dragreset: on
    ghost: on
    removeClasses: '.'+GDotUI.Theme.Icon.class
    invokeEvent: 'click'
    selectEvent: 'click'
    removeable: on
    sortable: off
    dropppables: ''
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.setStyle 'position','relative'
    #@remove = new Core.Icon {image: @options.icons.remove}
    #@handles = new Core.Icon {image: @options.icons.handle}
    #@handles.base.addClass  @options.classes.handle
    
    #$$(@remove.base,@handles.base).setStyle 'position','absolute'
    @title = new Element 'div'
    @subtitle = new Element 'div'
    @base.adopt @title,@subtitle
    #if @options.removeable
    #  @base.grab @remove
    #if @options.sortable
    #  @base.grab @handle
    @base.addEvent @options.selectEvent, ( (e)->
      @fireEvent 'select', [@,e]
      ).bindWithEvent @
    @base.addEvent @options.invokeEvent, ( ->
      if @enabled and not @options.draggable and not @editing
        @fireEvent 'invoked', @
    ).bindWithEvent @
    @addEvent 'dropped', ( (el,drop,e) ->
      @fireEvent 'invoked', [@ ,e, drop]
    ).bindWithEvent @
    @base.addEvent 'dblclick', ( ->
      if @enabled
        if @editing
          @fireEvent 'edit', @
    ).bindWithEvent @
    #@remove.addEvent 'invoked', ( ->
    #  @fireEvent 'delete', @
    #).bindWithEvent @
    @
  toggleEdit: ->
    if @editing
      if @options.draggable
        @drag.attach()
      @remove.base.setStyle 'right', -@remove.base.getSize().x
      @handles.base.setStyle 'left', -@handles.base.getSize().x
      @base.setStyle 'padding-left' , @base.retrieve( 'padding-left:old')
      @base.setStyle 'padding-right', @base.retrieve( 'padding-right:old')
      @editing = off
    else
      if @options.draggable
        @drag.detach()
      @remove.base.setStyle 'right', @options.offset
      @handles.base.setStyle 'left', @options.offset
      @base.store 'padding-left:old', @base.getStyle('padding-left')
      @base.store 'padding-right:old', @base.getStyle('padding-left')
      @base.setStyle 'padding-left', Number(@base.getStyle('padding-left').slice(0,-2))+@handles.base.getSize().x
      @base.setStyle 'padding-right', Number(@base.getStyle('padding-right').slice(0,-2))+@remove.base.getSize().x
      @editing = on
  ready: ->
    if not @editing
      #handSize = @handles.base.getSize()
      #remSize = @remove.base.getSize()
      baseSize = @base.getSize()
      #@remove.base.setStyles {
      #  "right":-remSize.x
      #  "top":(baseSize.y-remSize.y)/2
      #  }
      #@handles.base.setStyles {
      #  "left":-handSize.x,
      #  "top":(baseSize.y-handSize.y)/2
      #  }
      @parent()
      if @options.draggable
        @drag.addEvent 'beforeStart',( ->
          #recalculate drops
          @fireEvent 'select', @
          ).bindWithEvent @
}


###
---

name: Blender

description: Blender Layout Engine for G.UI

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Core.Button
  - G.UI/Iterable.ListItem

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
    }
  }
  toggleFullScreen: (view) ->
    if !view.fullscreen 
      @emptyNeigbours()
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
        if val-5 < v and v < val+5
          ret.opp.push it
        v = it.get mod
        if val-5 < v and v < val+5
          ret.mod.push it
    ret 
  update: (e) ->
    @emptyNeigbours()
    @children.each (child)->
      child.resize()
      child.update()
    @calculateNeigbours()
  create: ->
    @i = 0
    @stack = {}
    @hooks = []
    @views = []
    window.addEvent 'keydown', ((e)->
      if e.key is 'up' and e.control
        @toggleFullScreen @get 'active'
    ).bind @
    window.addEvent 'resize', @update.bind @
    @addView new Blender.View({top:0,left:0,right:"100%",bottom:"100%"
      ,restrains: {top:yes,left:yes,right:yes,bottom:yes}
    })
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
    view.base.addEvent 'click',( ->
      @set 'active', view
    ).bind @
    view.addEvent 'split', @splitView.bind @
    view.addEvent 'content-change', ((e)->
      if e?
        content = new @stack[e]()
        view.set 'content', content
    ).bind @
  addToStack: (name,cls) ->
    @stack[name] = cls
    @updateToolBars()
  updateToolBars: ->
    @children.each (child)->
      child.toolbar.select.list.removeAll()
      Object.each @stack, (value,key)->
         @addItem new Iterable.ListItem({label:key,removeable:false,draggable:false})
      , child.toolbar.select
    , @
}


###
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Controls 
  - Interfaces.Enabled

provides: Core.Icon

...
###
Core.Icon = new Class {
  Extends: Core.Abstract
  Implements:[
    Interfaces.Enabled
    Interfaces.Controls
  ]
  Attributes: {
    image: {
      setter: (value) ->
        @base.setStyle 'background-image', 'url(' + value + ')'
        value
    }
    class: {
      value: GDotUI.Theme.Icon.class
    }
  }
  create: ->
    @base.addEvent 'click', ((e)->
      if @enabled
        @fireEvent 'invoked', [@, e]
    ).bind @
}


###
---

name: Blender.Corner

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Icon

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

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires: 
  - GDotUI
  - Core.Abstract
  - Interfaces.Children
  - Interfaces.Enabled

provides: Core.Picker
...
###
Core.Picker = new Class {
  Extends: Core.Abstract
  Implements: [
    Interfaces.Enabled
    Interfaces.Children
  ]
  Binds: ['show','hide','delegate']
  Attributes: {
    class: {
      value: GDotUI.Theme.Picker.class
    }
    offset: {
      value: GDotUI.Theme.Picker.offset
      setter: (value) ->
        value
    }
    position: {
      value: {x:'auto',y:'auto'}
      validator: (value) ->
        value.x? and value.y?
    }
    event: {
      value: GDotUI.Theme.Picker.event
      setter: (value, old) ->
        value
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
      value: GDotUI.Theme.Picker.picking
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
      el.addEvent @event, @show
  detach: ->
    if @attachedTo?
      @attachedTo.removeEvent @event, @show
      @attachedTo = null
  delegate: ->
    if @attachedTo?
      @attachedTo.fireEvent 'change', arguments
  show: (e,auto) ->
    auto = if auto? then auto else true
    document.body.grab @base
    if @attachedTo?
      @attachedTo.addClass @picking
    if e? then if e.stop? then e.stop()
    if auto
      @base.addEvent 'outerClick', @hide
  hide: (e,force) ->
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

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires: 
  - GDotUI
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

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires: 
  - Core.Abstract
  - Core.Button

provides: Dialog.Prompt

...
###
Dialog.Prompt = new Class {
  Extends:Core.Abstract
  Delegates: {
    picker: ['show','hide','attach']
  }
  Attributes: {
    class: {
      value: 'dialog-prompt'
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
    labelClass: {
      value: 'dialog-prompt-label'
      setter: (value, old) ->
        value = String.from value
        @labelDiv.removeClass old
        @labelDiv.addClass value
        value
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @labelDiv = new Element 'div'
    @input = new Element 'input',{type:'text'}
    @button = new Core.Button()
    @base.adopt @labelDiv, @input, @button
    @picker = new Core.Picker()
    @picker.set 'content', @base
    @button.addEvent 'invoked', ((el,e)->
      @fireEvent 'invoked', @input.get('value')
    ).bind @
}


###
---

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

requires: [GDotUI]
...
###
Iterable.List = new Class {
  Extends:Core.Abstract
  options:{
    class: GDotUI.Theme.List.class
    selected: GDotUI.Theme.List.selected
    search: off
  }
  Attributes: {
    selected: {
      getter: ->
        @items.filter(((item) ->
          if item.base.hasClass @options.selected then true else false
        ).bind(@))[0]
      setter: (value, old) ->
        if value?
          if old != value
            if old
              old.base.removeClass @options.selected
            value.base.addClass @options.selected
        value
        
    }
  }
  initialize: (options) ->
    @parent options
  create: ->
    @base.addClass @options.class
    @sortable = new Sortables null
    @editing = off
    if @options.search
      @sinput = new Element 'input', {class:'search'}
      @base.grab @sinput
      @sinput.addEvent 'keyup', ( ->
          @search()
      ).bindWithEvent @
    @items = []
  ready: ->
  search: ->
    svalue = @sinput.get 'value'
    @items.each ( (item) ->
      if item.title.get('text').test(/#{svalue}/ig) or item.subtitle.get('text').test(/#{svalue}/ig)
        item.base.setStyle 'display', 'block'
      else
        item.base.setStyle 'display', 'none'
    ).bind @
  removeItem: (li) ->
    li.removeEvents 'invoked', 'edit', 'delete'
    @items.erase li
    li.base.destroy()
  removeAll: ->
    if @options.search
      @sinput.set 'value', ''
    @selected = null
    @base.empty()
    @items.empty()
  toggleEdit: ->
    bases = @items.map (item) ->
      return item.base
    if @editing
      @sortable.removeItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = off
    else
      @sortable.addItems bases
      @items.each (item) ->
        item.toggleEdit()
      @editing = on
  getItemFromTitle: (title) ->
    filtered = @items.filter (item) ->
      if String.from(item.title.get('text')).toLowerCase() is String(title).toLowerCase()
        yes
      else no
    filtered[0]
  addItem: (li) -> 
    @items.push li
    @base.grab li
    li.addEvent 'select', ( (item,e)->
      @set 'selected', item 
      ).bindWithEvent @
    li.addEvent 'invoked', ( (item) ->
      @fireEvent 'invoked', arguments
      ).bindWithEvent @
    li.addEvent 'edit', ( -> 
      @fireEvent 'edit', arguments
      ).bindWithEvent @
    li.addEvent 'delete', ( ->
      @fireEvent 'delete', arguments
      ).bindWithEvent @
}


###
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires:
  - GDotUI
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
    Interfaces.Enabled
    Interfaces.Size
    Interfaces.Children]
  Attributes: {
    class: {
      value: GDotUI.Theme.Select.class
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
          document.id(@removeIcon).dispose()
          document.id(@addIcon).dispose()
        value
    }
    value: {
      setter: (value) ->
        @list.set 'selected', @list.getItemFromTitle(value)
      getter: ->
        li = @list.get('selected')
        if li?
          li.label
    }
    textClass: {
      value: GDotUI.Theme.Select.textClass
      setter: (value, old) ->
        @text.removeClass old
        @text.addClass value
        value 
    }
    removeClass: {
      value: GDotUI.Theme.Select.removeClass
      setter: (value, old) ->
        @removeIcon.base.removeClass old
        @removeIcon.base.addClass value
        value 
    }
    addClass: {
      value: GDotUI.Theme.Select.addClass
      setter: (value, old) ->
        @addIcon.base.removeClass old
        @addIcon.base.addClass value
        value 
    }
    listClass: {
      value: GDotUI.Theme.Select.listClass
      setter: (value) ->
        @list.set 'class', value
    }
    listItemClass: {
      value: GDotUI.Theme.Select.listItemClass
    }
  }
  ready: ->
    @set 'size', @size
  create: ->
    
    @addEvent 'sizeChange', ( ->
      @list.base.setStyle 'width', if @size < @minSize then @minSize else @size
    ).bind @
    
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
    @text.addEvent 'mousewheel', ((e)->
      e.stop()
      index = @list.items.indexOf(@list.selected)+e.wheel
      if index < 0 then index = @list.items.length-1
      if index is @list.items.length then index = 0
      @list.set 'selected', @list.items[index]
    ).bind @
    @addIcon = new Core.Icon()
    @addIcon.base.set 'text', '+'
    @removeIcon = new Core.Icon()
    @removeIcon.base.set 'text', '-'
    $$(@addIcon.base,@removeIcon.base).setStyles {
      'z-index': '1'
      'position': 'relative'
    }
    @removeIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @removeItem @list.get('selected')
        @text.set 'text', @default or ''
    ).bind @
    @addIcon.addEvent 'invoked',( (el,e)->
      e.stop()
      if @enabled
        @prompt.show()
    ).bind @
    
    @picker = new Core.Picker({offset:0,position:{x:'center',y:'auto'}})
    @picker.attach @base, false
    @base.addEvent 'click', ((e) ->
      if @enabled
        @picker.show e
    ).bind @
    @list = new Iterable.List()
    @picker.set 'content', @list
    @base.adopt @text
    
    @prompt = new Dialog.Prompt();
    @prompt.set 'label', 'Add item:'
    @prompt.attach @base, false
    @prompt.addEvent 'invoked', ((value) ->
      if value
        item = new Iterable.ListItem {label:value,removeable:false,draggable:false}
        @addItem item
        @list.set 'selected', item
      @prompt.hide null, yes
    ).bind @
    
    @list.addEvent 'selectedChange', ( ->
      item = @list.selected
      @text.set 'text', item.label
      @fireEvent 'change', item.label
      @picker.hide null, yes
    ).bind @
    @update()
    
  addItem: (item) ->
    item.base.set 'class', @listItemClass
    @list.addItem item
  removeItem: (item) ->
    @list.removeItem item
}


###
---

name: Blender.Toolbar

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Data.Select

provides: Blender.Toolbar

...
###
Blender.Toolbar = new Class {
  Extends: Core.Abstract
  Implements: Interfaces.Children
  Attributes: {
    class: {
      value: 'blender-toolbar'
    }
  }
  create: ->
    @select = new Data.Select({editable:false,size:80});
    @addChild @select
}


###
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires: 
  - GDotUI
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
      value: GDotUI.Theme.Slider.classes.base
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
            @minSize = Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'min-width')
            @modifier = 'width'
            @drag.options.modifiers = {x: 'width',y:''}
            @drag.options.invert = false
            if not @size?
              size = Number.from getCSS("/\\.#{@get('class')}.horizontal$/",'width')
            @set 'size', size
            @progress.set 'style', ''
            @progress.setStyles {
              position: 'absolute'
              top: 0
              bottom: 0
              left: 0
            } 
          when 'vertical'
            @minSize = Number.from getCSS("/\\.#{@get('class')}.vertical$/",'min-hieght')
            @modifier = 'height'
            @drag.options.modifiers = {x: '',y: 'height'}
            @drag.options.invert = true
            if not @size?
              size = Number.from getCSS("/\\.#{@class}.vertical$/",'height')
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
    bar: {
      value: GDotUI.Theme.Slider.classes.bar
      setter: (value, old) ->
        @progress.removeClass old
        @progress.addClass value
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
    size: {
      setter: (value, old) ->
        if !value?
          value = old
        if @minSize > value
          value = @minSize
        @base.setStyle @modifier, value
        @progress.setStyle @modifier, if @reset then value/2 else @value/@steps*value
        value
    }
    value: {
      value: 0
      setter: (value) ->
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
    }
  }
  create: ->
    @progress = new Element "div"
         
    @base.adopt @progress
    
    @drag = new Drag @progress, {handle:@base}
    @drag.addEvent 'beforeStart', ( (el,e) ->
      @lastpos = Math.round((Number.from(el.getStyle(@modifier))/@size)*@steps)
      if not @enabled
        @disabledTop = el.getStyle @modifier
    ).bind @
    @drag.addEvent 'complete', ( (el,e) ->
      if @reset
        if @enabled
          el.setStyle @modifier, @size/2+"px"
      @fireEvent 'complete'
    ).bind @
    @drag.addEvent 'drag', ( (el,e) ->
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
    ).bind @
    @base.addEvent 'mousewheel', ( (e) ->
      e.stop()
      if @enabled
        @set 'value', @value+Number.from(e.wheel)
        @fireEvent 'step', @value
    ).bind @

}


###
---

name: Blender.View

description: Viewport

license: MIT-style license.

requires: 
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Core.Slider
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
        @base.setStyle 'top', value+1
        value
    }
    left: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getSize().x*Number.from(value)/100
        @base.setStyle 'left', value
        value
    }
    right: {
      setter: (value) ->
        winsize = window.getSize()
        if String.from(value).test(/%$/)
          value = winsize.x*Number.from(value)/100
        @base.setStyle 'right',  window.getSize().x-value+1
        value
    }
    restrains: {
      value: {top: no, left: no, right: no, bottom: no}
    }
    bottom: {
      setter: (value) ->
        if String.from(value).test(/%$/)
          value = window.getSize().y*Number.from(value)/100
        @base.setStyle 'bottom', window.getSize().y-value
        value
    }
    content: {
      value: null
      setter: (newVal,oldVal)->
        @removeChild oldVal
        @addChild newVal, 'top'
        newVal
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
    width = @base.getSize().x-10
    if @slider.base.isVisible()
      width -= 20
    @children.each ((child) ->
      child.set 'size', width
    ).bind @
    @slider.set 'size', @base.getSize().y-60
    if @base.getSize().y < @base.getScrollSize().y
      @slider.show()
    else
      @slider.hide()
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
    @slider = new Core.Slider({steps:100,mode:'vertical'})
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
        if (dir is 'bottom' or dir is 'top') and !@restrains.top
          @drag.startpos = {y:Number.from(@base.getStyle('top'))}
          @drag.options.modifiers = {x:null,y:'top'}
          @drag.options.invert = true
          @drag.start(e)
        
        if (dir is 'left' or dir is 'right') and !@restrains.right
          @drag.startpos = {x:Number.from(@get('right'))}
          @drag.options.modifiers = {x:'right',y:null}
          @drag.options.invert = true
          @drag.start(e)
    ).bind @
    @bottomRightCorner = new Blender.Corner({class:'bottomleft'})
    @bottomRightCorner.addEvent 'directionChange',((dir,e) ->
      if (dir is 'bottom' or dir is 'top') and !@restrains.bottom
        @drag.startpos = {y:Number.from(@get('bottom'))}
        @drag.options.modifiers = {x:null,y:'bottom'}
        @drag.options.invert = true
        @drag.start(e)
      if (dir is 'left' or dir is 'right') and !@restrains.left
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

