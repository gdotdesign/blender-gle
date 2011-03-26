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
