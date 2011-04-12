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
