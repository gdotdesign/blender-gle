/*
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
*/var Blender, Core, Data, Dialog, Forms, GDotUI, Interfaces, Iterable, Layout, Pickers, getCSS;
Class.Singleton = new Class({
  initialize: function(classDefinition, options) {
    var singletonClass;
    singletonClass = new Class(classDefinition);
    return new singletonClass(options);
  }
});
Class.Mutators.Delegates = function(delegations) {
  return new Hash(delegations).each(function(delegates, target) {
    return $splat(delegates).each(function(delegate) {
      return this.prototype[delegate] = function() {
        var ret;
        ret = this[target][delegate].apply(this[target], arguments);
        if (ret === this[target]) {
          return this;
        } else {
          return ret;
        }
      };
    }, this);
  }, this);
};
Class.Mutators.Attributes = function(attributes) {
  var $getter, $setter;
  $setter = attributes.$setter;
  $getter = attributes.$getter;
  if (this.prototype.$attributes) {
    attributes = Object.merge(this.prototype.$attributes, attributes);
  }
  delete attributes.$setter;
  delete attributes.$getter;
  this.implement(new Events);
  return this.implement({
    $attributes: attributes,
    get: function(name) {
      var attr;
      attr = this.$attributes[name];
      if (attr) {
        if (attr.valueFn && !attr.initialized) {
          attr.initialized = true;
          attr.value = attr.valueFn.call(this);
        }
        if (attr.getter) {
          return attr.getter.call(this, attr.value);
        } else {
          return attr.value;
        }
      } else {
        if ($getter) {
          return $getter.call(this, name);
        } else {
          return;
        }
      }
    },
    set: function(name, value) {
      var attr, newVal, oldVal;
      attr = this.$attributes[name];
      if (attr) {
        if (!attr.readOnly) {
          oldVal = attr.value;
          if (!attr.validator || attr.validator.call(this, value)) {
            if (attr.setter) {
              newVal = attr.setter.attempt([value, oldVal], this);
            } else {
              newVal = value;
            }
            attr.value = newVal;
            this[name] = newVal;
            this.update();
            if (oldVal !== newVal) {
              this.fireEvent(name + 'Change', {
                newVal: newVal,
                oldVal: oldVal
              });
            }
            return newVal;
          }
        }
      } else if ($setter) {
        return $setter.call(this, name, value);
      }
    },
    setAttributes: function(attributes) {
      attributes = Object.merge({}, attributes);
      return Object.each(this.$attributes, function(value, name) {
        if (attributes[name] != null) {
          return this.set(name, attributes[name]);
        } else if (value.value != null) {
          return this.set(name, value.value);
        }
      }, this);
    },
    getAttributes: function() {
      attributes = {};
      $each(this.$attributes, function(value, name) {
        return attributes[name] = this.get(name);
      }, this);
      return attributes;
    },
    addAttributes: function(attributes) {
      return $each(attributes, function(value, name) {
        return this.addAttribute(name, value);
      }, this);
    },
    addAttribute: function(name, value) {
      this.$attributes[name] = value;
      return this;
    }
  });
};
/*
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
*/
Element.Properties.checked = {
  get: function() {
    if (this.getChecked != null) {
      return this.getChecked();
    }
  },
  set: function(value) {
    this.setAttribute('checked', value);
    if ((this.on != null) && (this.off != null)) {
      if (value) {
        return this.on();
      } else {
        return this.off();
      }
    }
  }
};
(function() {
  return Color.implement({
    type: 'hex',
    alpha: '',
    setType: function(type) {
      return this.type = type;
    },
    setAlpha: function(alpha) {
      return this.alpha = alpha;
    },
    hsvToHsl: function() {
      var h, hsl, l, s, v;
      h = this.hsb[0];
      s = this.hsb[1];
      v = this.hsb[2];
      l = (2 - s / 100) * v / 2;
      hsl = [h, s * v / (l < 50 ? l * 2 : 200 - l * 2), l];
      if (isNaN(hsl[1])) {
        hsl[1] = 0;
      }
      return hsl;
    },
    format: function(type) {
      if (type) {
        this.setType(type);
      }
      switch (this.type) {
        case "rgb":
          return String.from("rgb(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ")");
        case "rgba":
          return String.from("rgba(" + this.rgb[0] + ", " + this.rgb[1] + ", " + this.rgb[2] + ", " + (this.alpha / 100) + ")");
        case "hsl":
          this.hsl = this.hsvToHsl();
          return String.from("hsl(" + this.hsl[0] + ", " + this.hsl[1] + "%, " + this.hsl[2] + "%)");
        case "hsla":
          this.hsl = this.hsvToHsl();
          return String.from("hsla(" + this.hsl[0] + ", " + this.hsl[1] + "%, " + this.hsl[2] + "%, " + (this.alpha / 100) + ")");
        case "hex":
          return String.from(this.hex);
      }
    }
  });
})();
(function() {
  var oldPrototypeStart;
  oldPrototypeStart = Drag.prototype.start;
  return Drag.prototype.start = function() {
    window.fireEvent('outer');
    return oldPrototypeStart.run(arguments, this);
  };
})();
(function() {
  Element.Events.outerClick = {
    base: 'mousedown',
    condition: function(event) {
      event.stopPropagation();
      return false;
    },
    onAdd: function(fn) {
      window.addEvent('click', fn);
      return window.addEvent('outer', fn);
    },
    onRemove: function(fn) {
      window.removeEvent('click', fn);
      return window.removeEvent('outer', fn);
    }
  };
  return Element.implement({
    oldGrab: Element.prototype.grab,
    oldInject: Element.prototype.inject,
    oldAdopt: Element.prototype.adopt,
    oldPosition: Element.prototype.position,
    position: function(options) {
      var asize, ofa, op, position, size, winscroll, winsize;
      op = {
        relativeTo: document.body,
        position: {
          x: 'center',
          y: 'center'
        }
      };
      options = Object.merge(op, options);
      winsize = window.getSize();
      winscroll = window.getScroll();
      asize = options.relativeTo.getSize();
      position = options.relativeTo.getPosition();
      size = this.getSize();
      if (options.position.x === 'auto') {
        if ((position.x + size.x + asize.x) > (winsize.x - winscroll.x)) {
          options.position.x = 'left';
        } else {
          options.position.x = 'right';
        }
      }
      if (options.position.y === 'auto') {
        if ((position.y + size.y + asize.y) > (winsize.y - winscroll.y)) {
          options.position.y = 'top';
        } else {
          options.position.y = 'bottom';
        }
      }
      ofa = {
        x: 0,
        y: 0
      };
      console.log(options.position);
      switch (options.position.x) {
        case 'center':
          if (options.position.y !== 'center') {
            ofa.x = -size.x / 2;
          }
          break;
        case 'left':
          ofa.x = -(options.offset + size.x);
          break;
        case 'right':
          ofa.x = options.offset;
      }
      switch (options.position.y) {
        case 'center':
          if (options.position.x !== 'center') {
            ofa.y = -size.y / 2;
          }
          break;
        case 'top':
          ofa.y = -(options.offset + size.y);
          break;
        case 'bottom':
          ofa.y = options.offset;
      }
      options.offset = ofa;
      console.log(ofa);
      return this.oldPosition.attempt(options, this);
    },
    removeTransition: function() {
      this.store('transition', this.getStyle('-webkit-transition-duration'));
      return this.setStyle('-webkit-transition-duration', '0');
    },
    addTransition: function() {
      this.setStyle('-webkit-transition-duration', this.retrieve('transition'));
      return this.eliminate('transition');
    },
    inTheDom: function() {
      if (this.parentNode) {
        if (this.parentNode.tagName.toLowerCase() === "html") {
          return true;
        } else {
          return $(this.parentNode).inTheDom;
        }
      } else {
        return false;
      }
    },
    grab: function(el, where) {
      var e;
      this.oldGrab.attempt(arguments, this);
      e = document.id(el);
      if (e.fireEvent != null) {
        e.fireEvent('addedToDom');
      }
      return this;
    },
    inject: function(el, where) {
      this.oldInject.attempt(arguments, this);
      this.fireEvent('addedToDom');
      return this;
    },
    adopt: function() {
      var elements;
      this.oldAdopt.attempt(arguments, this);
      elements = Array.flatten(arguments);
      elements.each(function(el) {
        var e;
        e = document.id(el);
        if (e.fireEvent != null) {
          return document.id(el).fireEvent('addedToDom');
        }
      });
      return this;
    }
  });
})();
/*
---

name: GDotUI

description: G.UI

license: MIT-style license.

provides: GDotUI

requires: [Class.Delegates, Element.Extras]

...
*/
Interfaces = {};
Layout = {};
Core = {};
Data = {};
Iterable = {};
Pickers = {};
Forms = {};
Dialog = {};
if (!(typeof GDotUI != "undefined" && GDotUI !== null)) {
  GDotUI = {};
}
GDotUI.Config = {
  tipZindex: 100,
  floatZindex: 0,
  cookieDuration: 7 * 1000
};
/*
---

name: Interfaces.Mux

description: Runs function which names start with _$ after initialization. (Initialization for interfaces)

license: MIT-style license.

provides: Interfaces.Mux

requires:
  - GDotUI

...
*/
Interfaces.Mux = new Class({
  mux: function() {
    return new Hash(this).each(function(value, key) {
      if (key.test(/^_\$/) && typeOf(value) === "function") {
        return value.attempt(null, this);
      }
    }, this);
  }
});
/*
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
*/
getCSS = function(selector, property) {
  var checkStyleSheet, ret;
  ret = null;
  checkStyleSheet = function(stylesheet) {
    try {
      if (stylesheet.cssRules != null) {
        return $A(stylesheet.cssRules).each(function(rule) {
          if (rule.styleSheet != null) {
            checkStyleSheet(rule.styleSheet);
          }
          if (rule.selectorText != null) {
            if (rule.selectorText.test(eval(selector))) {
              return ret = rule.style.getPropertyValue(property);
            }
          }
        });
      }
    } catch (error) {
      return console.log(error);
    }
  };
  $A(document.styleSheets).each(function(stylesheet) {
    return checkStyleSheet(stylesheet);
  });
  return ret;
};
Core.Abstract = new Class({
  Implements: [Events, Interfaces.Mux],
  Attributes: {
    "class": {
      setter: function(value, old) {
        value = String.from(value);
        this.base.removeClass(old);
        this.base.addClass(value);
        return value;
      }
    }
  },
  initialize: function(options) {
    this.base = new Element('div');
    this.base.addEvent('addedToDom', this.ready.bind(this));
    this.mux();
    this.create();
    this.setAttributes(options);
    return this;
  },
  create: function() {},
  update: function() {},
  ready: function() {
    return this.base.removeEvents('addedToDom');
  },
  toElement: function() {
    return this.base;
  }
});
/*
---

name: Interfaces.Children

description:

license: MIT-style license.

requires:
  - GDotUI

provides: Interfaces.Children

...
*/
Interfaces.Children = new Class({
  _$Children: function() {
    return this.children = [];
  },
  hasChild: function(child) {
    if (this.children.indexOf(child === -1)) {
      return false;
    } else {
      return true;
    }
  },
  adoptChildren: function() {
    var children;
    children = Array.from(arguments);
    this.children.append(children);
    return this.base.adopt(arguments);
  },
  addChild: function(el, where) {
    this.children.push(el);
    return this.base.grab(el, where);
  },
  removeChild: function(el) {
    if (this.children.contains(el)) {
      this.children.erase(el);
      document.id(el).dispose();
      return delete el;
    }
  },
  empty: function() {
    return this.children.each(function(child) {
      return this.removeChild(child);
    }, this);
  }
});
/*
---

name: Interfaces.Enabled

description: Provides enable and disable function to elements.

license: MIT-style license.

provides: Interfaces.Enabled

requires:
  - GDotUI
...
*/
Interfaces.Enabled = new Class({
  _$Enabled: function() {
    return this.enabled = true;
  },
  supress: function() {
    if (this.children != null) {
      this.children.each(function(item) {
        if (item.disable != null) {
          return item.supress();
        }
      });
    }
    this.base.addClass('supressed');
    return this.enabled = false;
  },
  unsupress: function() {
    if (this.children != null) {
      this.children.each(function(item) {
        if (item.enable != null) {
          return item.unsupress();
        }
      });
    }
    this.base.removeClass('supressed');
    return this.enabled = true;
  },
  enable: function() {
    if (this.children != null) {
      this.children.each(function(item) {
        if (item.enable != null) {
          return item.unsupress();
        }
      });
    }
    this.enabled = true;
    this.base.removeClass('disabled');
    return this.fireEvent('enabled');
  },
  disable: function() {
    if (this.children != null) {
      this.children.each(function(item) {
        if (item.disable != null) {
          return item.supress();
        }
      });
    }
    this.enabled = false;
    this.base.addClass('disabled');
    return this.fireEvent('disabled');
  }
});
/*
---

name: Interfaces.Controls

description: Some control functions.

license: MIT-style license.

provides: Interfaces.Controls

requires:
  - GDotUI
  - Interfaces.Enabled

...
*/
Interfaces.Controls = new Class({
  Implements: Interfaces.Enabled,
  show: function() {
    if (this.enabled) {
      return this.base.show();
    }
  },
  hide: function() {
    if (this.enabled) {
      return this.base.hide();
    }
  },
  toggle: function() {
    if (this.enabled) {
      return this.base.toggle();
    }
  }
});
/*
---

name: Interfaces.Size

description: Size minsize from css....

license: MIT-style license.

provides: Interfaces.Size

requires: [GDotUI]
...
*/
Interfaces.Size = new Class({
  _$Size: function() {
    this.size = Number.from(getCSS("/\\." + (this.get('class')) + "$/", 'width'));
    this.minSize = Number.from(getCSS("/\\." + (this.get('class')) + "$/", 'min-width')) || 0;
    this.addAttribute('minSize', {
      value: null,
      setter: function(value, old) {
        this.base.setStyle('min-width', value);
        return value;
      }
    });
    return this.addAttribute('size', {
      value: null,
      setter: function(value, old) {
        var size;
        size = value < this.minSize ? this.minSize : value;
        this.base.setStyle('width', size);
        return size;
      }
    });
  }
});
/*
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
*/
Core.Button = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls, Interfaces.Size],
  Attributes: {
    label: {
      value: GDotUI.Theme.Button.label,
      setter: function(value) {
        this.base.set('text', value);
        return value;
      }
    },
    "class": {
      value: GDotUI.Theme.Button["class"]
    }
  },
  create: function() {
    return this.base.addEvent('click', (function(e) {
      if (this.enabled) {
        return this.fireEvent('invoked', [this, e]);
      }
    }).bind(this));
  }
});
/*
---

name: Interfaces.Draggable

description: Porived dragging for elements that implements it.

license: MIT-style license.

provides: [Interfaces.Draggable, Drag.Float, Drag.Ghost]

requires: [GDotUI]
...
*/
Drag.Float = new Class({
  Extends: Drag.Move,
  initialize: function(el, options) {
    return this.parent(el, options);
  },
  start: function(event) {
    if (this.options.target === event.target) {
      return this.parent(event);
    }
  }
});
Drag.Ghost = new Class({
  Extends: Drag.Move,
  options: {
    opacity: 0.65,
    pos: false,
    remove: ''
  },
  start: function(event) {
    if (!event.rightClick) {
      this.droppables = $$(this.options.droppables);
      this.ghost();
      return this.parent(event);
    }
  },
  cancel: function(event) {
    if (event) {
      this.deghost();
    }
    return this.parent(event);
  },
  stop: function(event) {
    this.deghost();
    return this.parent(event);
  },
  ghost: function() {
    this.element = (this.element.clone()).setStyles({
      'opacity': this.options.opacity,
      'position': 'absolute',
      'z-index': 5003,
      'top': this.element.getCoordinates()['top'],
      'left': this.element.getCoordinates()['left'],
      '-webkit-transition-duration': '0s'
    }).inject(document.body).store('parent', this.element);
    return this.element.getElements(this.options.remove).dispose();
  },
  deghost: function() {
    var e, newpos;
    e = this.element.retrieve('parent');
    newpos = this.element.getPosition(e.getParent());
    if (this.options.pos && this.overed === null) {
      e.setStyles({
        'top': newpos.y,
        'left': newpos.x
      });
    }
    this.element.destroy();
    return this.element = e;
  }
});
Interfaces.Draggable = new Class({
  Implements: Options,
  options: {
    draggable: false,
    ghost: false,
    removeClasses: ''
  },
  _$Draggable: function() {
    if (this.options.draggable) {
      if (this.handle === null) {
        this.handle = this.base;
      }
      if (this.options.ghost) {
        this.drag = new Drag.Ghost(this.base, {
          target: this.handle,
          handle: this.handle,
          remove: this.options.removeClasses,
          droppables: this.options.droppables,
          precalculate: true,
          pos: true
        });
      } else {
        this.drag = new Drag.Float(this.base, {
          target: this.handle,
          handle: this.handle
        });
      }
      return this.drag.addEvent('drop', (function() {
        return this.fireEvent('dropped', arguments);
      }).bindWithEvent(this));
    }
  }
});
/*
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires: [GDotUI, Interfaces.Draggable]
...
*/
Iterable.ListItem = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Draggable, Interfaces.Enabled],
  Attributes: {
    label: {
      value: '',
      setter: function(value) {
        this.title.set('text', value);
        return value;
      }
    },
    "class": {
      value: GDotUI.Theme.ListItem["class"]
    }
  },
  options: {
    classes: {
      title: GDotUI.Theme.ListItem.title,
      subtitle: GDotUI.Theme.ListItem.subTitle
    },
    title: '',
    subtitle: '',
    draggable: false,
    dragreset: true,
    ghost: true,
    removeClasses: '.' + GDotUI.Theme.Icon["class"],
    invokeEvent: 'click',
    selectEvent: 'click',
    removeable: true,
    sortable: false,
    dropppables: ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.setStyle('position', 'relative');
    this.title = new Element('div');
    this.subtitle = new Element('div');
    this.base.adopt(this.title, this.subtitle);
    this.base.addEvent(this.options.selectEvent, (function(e) {
      return this.fireEvent('select', [this, e]);
    }).bindWithEvent(this));
    this.base.addEvent(this.options.invokeEvent, (function() {
      if (this.enabled && !this.options.draggable && !this.editing) {
        return this.fireEvent('invoked', this);
      }
    }).bindWithEvent(this));
    this.addEvent('dropped', (function(el, drop, e) {
      return this.fireEvent('invoked', [this, e, drop]);
    }).bindWithEvent(this));
    this.base.addEvent('dblclick', (function() {
      if (this.enabled) {
        if (this.editing) {
          return this.fireEvent('edit', this);
        }
      }
    }).bindWithEvent(this));
    return this;
  },
  toggleEdit: function() {
    if (this.editing) {
      if (this.options.draggable) {
        this.drag.attach();
      }
      this.remove.base.setStyle('right', -this.remove.base.getSize().x);
      this.handles.base.setStyle('left', -this.handles.base.getSize().x);
      this.base.setStyle('padding-left', this.base.retrieve('padding-left:old'));
      this.base.setStyle('padding-right', this.base.retrieve('padding-right:old'));
      return this.editing = false;
    } else {
      if (this.options.draggable) {
        this.drag.detach();
      }
      this.remove.base.setStyle('right', this.options.offset);
      this.handles.base.setStyle('left', this.options.offset);
      this.base.store('padding-left:old', this.base.getStyle('padding-left'));
      this.base.store('padding-right:old', this.base.getStyle('padding-left'));
      this.base.setStyle('padding-left', Number(this.base.getStyle('padding-left').slice(0, -2)) + this.handles.base.getSize().x);
      this.base.setStyle('padding-right', Number(this.base.getStyle('padding-right').slice(0, -2)) + this.remove.base.getSize().x);
      return this.editing = true;
    }
  },
  ready: function() {
    var baseSize;
    if (!this.editing) {
      baseSize = this.base.getSize();
      this.parent();
      if (this.options.draggable) {
        return this.drag.addEvent('beforeStart', (function() {
          return this.fireEvent('select', this);
        }).bindWithEvent(this));
      }
    }
  }
});
/*
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
*/
Blender = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Children,
  Attributes: {
    "class": {
      value: 'blender-layout'
    },
    active: {
      value: null
    }
  },
  toggleFullScreen: function(view) {
    if (!view.fullscreen) {
      this.emptyNeigbours();
      view.lastPosition = {
        top: view.get('top'),
        bottom: view.get('bottom'),
        left: view.get('left'),
        right: view.get('right')
      };
      view.set('top', 0);
      view.set('bottom', '100%');
      view.set('left', 0);
      view.set('right', '100%');
      view.fullscreen = true;
      return view.base.setStyle('z-index', 100);
    } else {
      view.fullscreen = false;
      view.base.setStyle('z-index', 1);
      view.set('top', view.lastPosition.top);
      view.set('bottom', view.lastPosition.bottom);
      view.set('left', view.lastPosition.left);
      view.set('right', view.lastPosition.right);
      return this.calculateNeigbours();
    }
  },
  splitView: function(view, mode) {
    var bottom, left, right, top, view2;
    this.emptyNeigbours();
    view2 = new Blender.View();
    if (mode === 'vertical') {
      if (view.restrains.bottom) {
        view.restrains.bottom = false;
        view2.restrains.bottom = true;
      }
      top = view.get('top');
      bottom = view.get('bottom');
      view2.set('top', Math.floor(top + ((bottom - top) / 2)));
      view2.set('bottom', bottom);
      view2.set('left', view.get('left'));
      view2.set('right', view.get('right'));
      view.set('bottom', Math.floor(top + ((bottom - top) / 2)));
    }
    if (mode === 'horizontal') {
      if (view.restrains.right) {
        view.restrains.right = false;
        view2.restrains.right = true;
      }
      left = view.get('left');
      right = view.get('right');
      view2.set('top', view.get('top'));
      view2.set('bottom', view.get('bottom'));
      view2.set('left', Math.floor(left + ((right - left) / 2)));
      view2.set('right', right);
      view.set('right', Math.floor(left + ((right - left) / 2)));
    }
    this.addView(view2);
    this.calculateNeigbours();
    return this.updateToolBars();
  },
  getSimilar: function(item, prop) {
    var mod, opp, ret, val;
    mod = prop;
    switch (mod) {
      case 'right':
        opp = 'left';
        break;
      case 'left':
        opp = 'right';
        break;
      case 'top':
        opp = 'bottom';
        break;
      case 'bottom':
        opp = 'top';
    }
    ret = {
      mod: [],
      opp: []
    };
    val = item.get(mod);
    this.children.each(function(it) {
      var v;
      if (it !== item) {
        v = it.get(opp);
        if (val - 5 < v && v < val + 5) {
          ret.opp.push(it);
        }
        v = it.get(mod);
        if (val - 5 < v && v < val + 5) {
          return ret.mod.push(it);
        }
      }
    });
    return ret;
  },
  update: function(e) {
    this.emptyNeigbours();
    this.children.each(function(child) {
      child.resize();
      return child.update();
    });
    return this.calculateNeigbours();
  },
  create: function() {
    this.i = 0;
    this.stack = {};
    this.hooks = [];
    this.views = [];
    window.addEvent('keydown', (function(e) {
      if (e.key === 'up' && e.control) {
        return this.toggleFullScreen(this.get('active'));
      }
    }).bind(this));
    window.addEvent('resize', this.update.bind(this));
    this.addView(new Blender.View({
      top: 0,
      left: 0,
      right: "100%",
      bottom: "100%",
      restrains: {
        top: true,
        left: true,
        right: true,
        bottom: true
      }
    }));
    return console.log('Blender Layout engine!');
  },
  emptyNeigbours: function() {
    return this.children.each((function(child) {
      child.hooks.right = {};
      child.hooks.top = {};
      child.hooks.bottom = {};
      return child.hooks.left = {};
    }).bind(this));
  },
  calculateNeigbours: function() {
    return this.children.each((function(child) {
      child.hooks.right = this.getSimilar(child, 'right');
      child.hooks.top = this.getSimilar(child, 'top');
      child.hooks.bottom = this.getSimilar(child, 'bottom');
      return child.hooks.left = this.getSimilar(child, 'left');
    }).bind(this));
  },
  removeView: function(view) {
    view.removeEvents('split');
    return this.removeChild(view);
  },
  addView: function(view) {
    this.addChild(view);
    view.base.addEvent('click', (function() {
      return this.set('active', view);
    }).bind(this));
    view.addEvent('split', this.splitView.bind(this));
    return view.addEvent('content-change', (function(e) {
      var content;
      if (e != null) {
        content = new this.stack[e]();
        return view.set('content', content);
      }
    }).bind(this));
  },
  addToStack: function(name, cls) {
    this.stack[name] = cls;
    return this.updateToolBars();
  },
  updateToolBars: function() {
    return this.children.each(function(child) {
      child.toolbar.select.list.removeAll();
      return Object.each(this.stack, function(value, key) {
        return this.addItem(new Iterable.ListItem({
          label: key,
          removeable: false,
          draggable: false
        }));
      }, child.toolbar.select);
    }, this);
  }
});
/*
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
*/
Core.Icon = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls],
  Attributes: {
    image: {
      setter: function(value) {
        this.base.setStyle('background-image', 'url(' + value + ')');
        return value;
      }
    },
    "class": {
      value: GDotUI.Theme.Icon["class"]
    }
  },
  create: function() {
    return this.base.addEvent('click', (function(e) {
      if (this.enabled) {
        return this.fireEvent('invoked', [this, e]);
      }
    }).bind(this));
  }
});
/*
---

name: Blender.Corner

description: Viewport

license: MIT-style license.

requires:
  - G.UI/Core.Icon

provides: Blender.Corner

...
*/
Blender.Corner = new Class({
  Extends: Core.Icon,
  Attributes: {
    snapDistance: {
      value: 0
    }
  },
  create: function() {
    this.drag = new Drag(this.base, {
      style: false
    });
    this.drag.addEvent('start', (function(el, e) {
      this.startPosition = e.page;
      return this.direction = null;
    }).bind(this));
    this.drag.addEvent('drag', (function(el, e) {
      var directions, maxdir, maxoffset, offsets;
      directions = [];
      offsets = [];
      if (this.startPosition.x < e.page.x) {
        directions.push('right');
        offsets.push(e.page.x - this.startPosition.x);
      }
      if (this.startPosition.x > e.page.x) {
        directions.push('left');
        offsets.push(this.startPosition.x - e.page.x);
      }
      if (this.startPosition.y < e.page.y) {
        directions.push('bottom');
        offsets.push(e.page.y - this.startPosition.y);
      }
      if (this.startPosition.y > e.page.y) {
        directions.push('top');
        offsets.push(this.startPosition.y - e.page.y);
      }
      maxdir = directions[offsets.indexOf(offsets.max())];
      maxoffset = offsets.max();
      if (maxoffset > this.snapDistance) {
        if (this.direction !== maxdir) {
          this.direction = maxdir;
          this.fireEvent('directionChange', [maxdir, e]);
          return this.drag.stop();
        }
      }
    }).bind(this));
    return this.parent();
  }
});
/*
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
*/
Core.Picker = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Children],
  Binds: ['show', 'hide', 'delegate'],
  Attributes: {
    "class": {
      value: GDotUI.Theme.Picker["class"]
    },
    offset: {
      value: GDotUI.Theme.Picker.offset,
      setter: function(value) {
        return value;
      }
    },
    position: {
      value: {
        x: 'auto',
        y: 'auto'
      },
      validator: function(value) {
        return (value.x != null) && (value.y != null);
      }
    },
    event: {
      value: GDotUI.Theme.Picker.event,
      setter: function(value, old) {
        return value;
      }
    },
    content: {
      value: null,
      setter: function(value, old) {
        if (old != null) {
          if (old["$events"]) {
            old.removeEvent('change', this.delegate);
          }
          this.removeChild(old);
        }
        this.addChild(value);
        if (value["$events"]) {
          value.addEvent('change', this.delegate);
        }
        return value;
      }
    },
    picking: {
      value: GDotUI.Theme.Picker.picking
    }
  },
  create: function() {
    return this.base.setStyle('position', 'absolute');
  },
  ready: function() {
    return this.base.position({
      relativeTo: this.attachedTo,
      position: this.position,
      offset: this.offset
    });
  },
  attach: function(el, auto) {
    auto = auto != null ? auto : true;
    if (this.attachedTo != null) {
      this.detach();
    }
    this.attachedTo = el;
    if (auto) {
      return el.addEvent(this.event, this.show);
    }
  },
  detach: function() {
    if (this.attachedTo != null) {
      this.attachedTo.removeEvent(this.event, this.show);
      return this.attachedTo = null;
    }
  },
  delegate: function() {
    if (this.attachedTo != null) {
      return this.attachedTo.fireEvent('change', arguments);
    }
  },
  show: function(e, auto) {
    auto = auto != null ? auto : true;
    document.body.grab(this.base);
    if (this.attachedTo != null) {
      this.attachedTo.addClass(this.picking);
    }
    if (e != null) {
      if (e.stop != null) {
        e.stop();
      }
    }
    if (auto) {
      return this.base.addEvent('outerClick', this.hide);
    }
  },
  hide: function(e, force) {
    if (force != null) {
      if (this.attachedTo != null) {
        this.attachedTo.removeClass(this.picking);
      }
      return this.base.dispose();
    } else if (e != null) {
      if (this.base.isVisible() && !this.base.hasChild(e.target)) {
        if (this.attachedTo != null) {
          this.attachedTo.removeClass(this.picking);
        }
        return this.base.dispose();
      }
    }
  }
});
/*
---

name: Data.Abstract

description: Abstract base class for data elements.

license: MIT-style license.

requires:
  - GDotUI
  - Core.Abstract

provides: Data.Abstract

...
*/
Data.Abstract = new Class({
  Extends: Core.Abstract,
  Attributes: {
    value: {
      value: null
    }
  }
});
/*
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires:
  - Core.Abstract
  - Core.Button

provides: Dialog.Prompt

...
*/
Dialog.Prompt = new Class({
  Extends: Core.Abstract,
  Delegates: {
    picker: ['show', 'hide', 'attach']
  },
  Attributes: {
    "class": {
      value: 'dialog-prompt'
    },
    label: {
      value: '',
      setter: function(value) {
        return this.labelDiv.set('text', value);
      }
    },
    buttonLabel: {
      value: 'Ok',
      setter: function(value) {
        return this.button.set('label', value);
      }
    },
    labelClass: {
      value: 'dialog-prompt-label',
      setter: function(value, old) {
        value = String.from(value);
        this.labelDiv.removeClass(old);
        this.labelDiv.addClass(value);
        return value;
      }
    }
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.labelDiv = new Element('div');
    this.input = new Element('input', {
      type: 'text'
    });
    this.button = new Core.Button();
    this.base.adopt(this.labelDiv, this.input, this.button);
    this.picker = new Core.Picker();
    this.picker.set('content', this.base);
    return this.button.addEvent('invoked', (function(el, e) {
      return this.fireEvent('invoked', this.input.get('value'));
    }).bind(this));
  }
});
/*
---

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

requires: [GDotUI]
...
*/
Iterable.List = new Class({
  Extends: Core.Abstract,
  options: {
    "class": GDotUI.Theme.List["class"],
    selected: GDotUI.Theme.List.selected,
    search: false
  },
  Attributes: {
    selected: {
      getter: function() {
        return this.items.filter((function(item) {
          if (item.base.hasClass(this.options.selected)) {
            return true;
          } else {
            return false;
          }
        }).bind(this))[0];
      },
      setter: function(value, old) {
        if (value != null) {
          if (old !== value) {
            if (old) {
              old.base.removeClass(this.options.selected);
            }
            value.base.addClass(this.options.selected);
          }
        }
        return value;
      }
    }
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options["class"]);
    this.sortable = new Sortables(null);
    this.editing = false;
    if (this.options.search) {
      this.sinput = new Element('input', {
        "class": 'search'
      });
      this.base.grab(this.sinput);
      this.sinput.addEvent('keyup', (function() {
        return this.search();
      }).bindWithEvent(this));
    }
    return this.items = [];
  },
  ready: function() {},
  search: function() {
    var svalue;
    svalue = this.sinput.get('value');
    return this.items.each((function(item) {
      if (item.title.get('text').test(/#{svalue}/ig) || item.subtitle.get('text').test(/#{svalue}/ig)) {
        return item.base.setStyle('display', 'block');
      } else {
        return item.base.setStyle('display', 'none');
      }
    }).bind(this));
  },
  removeItem: function(li) {
    li.removeEvents('invoked', 'edit', 'delete');
    this.items.erase(li);
    return li.base.destroy();
  },
  removeAll: function() {
    if (this.options.search) {
      this.sinput.set('value', '');
    }
    this.selected = null;
    this.base.empty();
    return this.items.empty();
  },
  toggleEdit: function() {
    var bases;
    bases = this.items.map(function(item) {
      return item.base;
    });
    if (this.editing) {
      this.sortable.removeItems(bases);
      this.items.each(function(item) {
        return item.toggleEdit();
      });
      return this.editing = false;
    } else {
      this.sortable.addItems(bases);
      this.items.each(function(item) {
        return item.toggleEdit();
      });
      return this.editing = true;
    }
  },
  getItemFromTitle: function(title) {
    var filtered;
    filtered = this.items.filter(function(item) {
      if (String.from(item.title.get('text')).toLowerCase() === String(title).toLowerCase()) {
        return true;
      } else {
        return false;
      }
    });
    return filtered[0];
  },
  addItem: function(li) {
    this.items.push(li);
    this.base.grab(li);
    li.addEvent('select', (function(item, e) {
      return this.set('selected', item);
    }).bindWithEvent(this));
    li.addEvent('invoked', (function(item) {
      return this.fireEvent('invoked', arguments);
    }).bindWithEvent(this));
    li.addEvent('edit', (function() {
      return this.fireEvent('edit', arguments);
    }).bindWithEvent(this));
    return li.addEvent('delete', (function() {
      return this.fireEvent('delete', arguments);
    }).bindWithEvent(this));
  }
});
/*
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
*/
Data.Select = new Class({
  Extends: Data.Abstract,
  Implements: [Interfaces.Controls, Interfaces.Enabled, Interfaces.Size, Interfaces.Children],
  Attributes: {
    "class": {
      value: GDotUI.Theme.Select["class"]
    },
    "default": {
      value: '',
      setter: function(value, old) {
        if (this.text.get('text') === (old || '')) {
          this.text.set('text', value);
        }
        return value;
      }
    },
    selected: {
      getter: function() {
        return this.list.get('selected');
      }
    },
    editable: {
      value: true,
      setter: function(value) {
        if (value) {
          this.adoptChildren(this.removeIcon, this.addIcon);
        } else {
          document.id(this.removeIcon).dispose();
          document.id(this.addIcon).dispose();
        }
        return value;
      }
    },
    value: {
      setter: function(value) {
        return this.list.set('selected', this.list.getItemFromTitle(value));
      },
      getter: function() {
        var li;
        li = this.list.get('selected');
        if (li != null) {
          return li.label;
        }
      }
    },
    textClass: {
      value: GDotUI.Theme.Select.textClass,
      setter: function(value, old) {
        this.text.removeClass(old);
        this.text.addClass(value);
        return value;
      }
    },
    removeClass: {
      value: GDotUI.Theme.Select.removeClass,
      setter: function(value, old) {
        this.removeIcon.base.removeClass(old);
        this.removeIcon.base.addClass(value);
        return value;
      }
    },
    addClass: {
      value: GDotUI.Theme.Select.addClass,
      setter: function(value, old) {
        this.addIcon.base.removeClass(old);
        this.addIcon.base.addClass(value);
        return value;
      }
    },
    listClass: {
      value: GDotUI.Theme.Select.listClass,
      setter: function(value) {
        return this.list.set('class', value);
      }
    },
    listItemClass: {
      value: GDotUI.Theme.Select.listItemClass
    }
  },
  ready: function() {
    return this.set('size', this.size);
  },
  create: function() {
    this.addEvent('sizeChange', (function() {
      return this.list.base.setStyle('width', this.size < this.minSize ? this.minSize : this.size);
    }).bind(this));
    this.base.setStyle('position', 'relative');
    this.text = new Element('div');
    this.text.setStyles({
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      'z-index': 0,
      overflow: 'hidden'
    });
    this.text.addEvent('mousewheel', (function(e) {
      var index;
      e.stop();
      index = this.list.items.indexOf(this.list.selected) + e.wheel;
      if (index < 0) {
        index = this.list.items.length - 1;
      }
      if (index === this.list.items.length) {
        index = 0;
      }
      return this.list.set('selected', this.list.items[index]);
    }).bind(this));
    this.addIcon = new Core.Icon();
    this.addIcon.base.set('text', '+');
    this.removeIcon = new Core.Icon();
    this.removeIcon.base.set('text', '-');
    $$(this.addIcon.base, this.removeIcon.base).setStyles({
      'z-index': '1',
      'position': 'relative'
    });
    this.removeIcon.addEvent('invoked', (function(el, e) {
      e.stop();
      if (this.enabled) {
        this.removeItem(this.list.get('selected'));
        return this.text.set('text', this["default"] || '');
      }
    }).bind(this));
    this.addIcon.addEvent('invoked', (function(el, e) {
      e.stop();
      if (this.enabled) {
        return this.prompt.show();
      }
    }).bind(this));
    this.picker = new Core.Picker({
      offset: 0,
      position: {
        x: 'center',
        y: 'auto'
      }
    });
    this.picker.attach(this.base, false);
    this.base.addEvent('click', (function(e) {
      if (this.enabled) {
        return this.picker.show(e);
      }
    }).bind(this));
    this.list = new Iterable.List();
    this.picker.set('content', this.list);
    this.base.adopt(this.text);
    this.prompt = new Dialog.Prompt();
    this.prompt.set('label', 'Add item:');
    this.prompt.attach(this.base, false);
    this.prompt.addEvent('invoked', (function(value) {
      var item;
      if (value) {
        item = new Iterable.ListItem({
          label: value,
          removeable: false,
          draggable: false
        });
        this.addItem(item);
        this.list.set('selected', item);
      }
      return this.prompt.hide(null, true);
    }).bind(this));
    this.list.addEvent('selectedChange', (function() {
      var item;
      item = this.list.selected;
      this.text.set('text', item.label);
      this.fireEvent('change', item.label);
      return this.picker.hide(null, true);
    }).bind(this));
    return this.update();
  },
  addItem: function(item) {
    item.base.set('class', this.listItemClass);
    return this.list.addItem(item);
  },
  removeItem: function(item) {
    return this.list.removeItem(item);
  }
});
/*
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
*/
Blender.Toolbar = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Children,
  Attributes: {
    "class": {
      value: 'blender-toolbar'
    }
  },
  create: function() {
    this.select = new Data.Select({
      editable: false,
      size: 80
    });
    return this.addChild(this.select);
  }
});
/*
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
*/
Core.Slider = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Controls, Interfaces.Enabled],
  Attributes: {
    "class": {
      value: GDotUI.Theme.Slider.classes.base
    },
    mode: {
      value: 'horizontal',
      setter: function(value, old) {
        var size;
        this.base.removeClass(old);
        this.base.addClass(value);
        this.base.set('style', '');
        this.base.setStyle('position', 'relative');
        switch (value) {
          case 'horizontal':
            this.minSize = Number.from(getCSS("/\\." + (this.get('class')) + ".horizontal$/", 'min-width'));
            this.modifier = 'width';
            this.drag.options.modifiers = {
              x: 'width',
              y: ''
            };
            this.drag.options.invert = false;
            if (!(this.size != null)) {
              size = Number.from(getCSS("/\\." + (this.get('class')) + ".horizontal$/", 'width'));
            }
            this.set('size', size);
            this.progress.set('style', '');
            this.progress.setStyles({
              position: 'absolute',
              top: 0,
              bottom: 0,
              left: 0
            });
            break;
          case 'vertical':
            this.minSize = Number.from(getCSS("/\\." + (this.get('class')) + ".vertical$/", 'min-hieght'));
            this.modifier = 'height';
            this.drag.options.modifiers = {
              x: '',
              y: 'height'
            };
            this.drag.options.invert = true;
            if (!(this.size != null)) {
              size = Number.from(getCSS("/\\." + this["class"] + ".vertical$/", 'height'));
            }
            this.set('size', size);
            this.progress.set('style', '');
            this.progress.setStyles({
              position: 'absolute',
              bottom: 0,
              left: 0,
              right: 0
            });
        }
        if (this.base.isVisible()) {
          this.set('value', this.value);
        }
        return value;
      }
    },
    bar: {
      value: GDotUI.Theme.Slider.classes.bar,
      setter: function(value, old) {
        this.progress.removeClass(old);
        this.progress.addClass(value);
        return value;
      }
    },
    reset: {
      value: false
    },
    steps: {
      value: 100
    },
    range: {
      value: [0, 0]
    },
    size: {
      setter: function(value, old) {
        if (!(value != null)) {
          value = old;
        }
        if (this.minSize > value) {
          value = this.minSize;
        }
        this.base.setStyle(this.modifier, value);
        this.progress.setStyle(this.modifier, this.reset ? value / 2 : this.value / this.steps * value);
        return value;
      }
    },
    value: {
      value: 0,
      setter: function(value) {
        var percent;
        if (!this.reset) {
          percent = Math.round((value / this.steps) * 100);
          if (value < 0) {
            this.progress.setStyle(this.modifier, 0);
            value = 0;
          }
          if (this.value > this.steps) {
            this.progress.setStyle(this.modifier, this.size);
            value = this.steps;
          }
          if (!(value < 0) && !(value > this.steps)) {
            this.progress.setStyle(this.modifier, (percent / 100) * this.size);
          }
        }
        return value;
      }
    }
  },
  create: function() {
    this.progress = new Element("div");
    this.base.adopt(this.progress);
    this.drag = new Drag(this.progress, {
      handle: this.base
    });
    this.drag.addEvent('beforeStart', (function(el, e) {
      this.lastpos = Math.round((Number.from(el.getStyle(this.modifier)) / this.size) * this.steps);
      if (!this.enabled) {
        return this.disabledTop = el.getStyle(this.modifier);
      }
    }).bind(this));
    this.drag.addEvent('complete', (function(el, e) {
      if (this.reset) {
        if (this.enabled) {
          el.setStyle(this.modifier, this.size / 2 + "px");
        }
      }
      return this.fireEvent('complete');
    }).bind(this));
    this.drag.addEvent('drag', (function(el, e) {
      var offset, pos;
      if (this.enabled) {
        pos = Number.from(el.getStyle(this.modifier));
        offset = Math.round((pos / this.size) * this.steps) - this.lastpos;
        this.lastpos = Math.round((Number.from(el.getStyle(this.modifier)) / this.size) * this.steps);
        if (pos > this.size) {
          el.setStyle(this.modifier, this.size);
          pos = this.size;
        } else {
          if (this.reset) {
            this.value += offset;
          }
        }
        if (!this.reset) {
          this.value = Math.round((pos / this.size) * this.steps);
        }
        this.fireEvent('step', this.value);
        return this.update();
      } else {
        return el.setStyle(this.modifier, this.disabledTop);
      }
    }).bind(this));
    return this.base.addEvent('mousewheel', (function(e) {
      e.stop();
      if (this.enabled) {
        this.set('value', this.value + Number.from(e.wheel));
        return this.fireEvent('step', this.value);
      }
    }).bind(this));
  }
});
/*
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
*/
Blender.View = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Children,
  Attributes: {
    "class": {
      value: 'blender-view'
    },
    top: {
      setter: function(value) {
        this.base.setStyle('top', value + 1);
        return value;
      }
    },
    left: {
      setter: function(value) {
        if (String.from(value).test(/%$/)) {
          value = window.getSize().x * Number.from(value) / 100;
        }
        this.base.setStyle('left', value);
        return value;
      }
    },
    right: {
      setter: function(value) {
        var winsize;
        winsize = window.getSize();
        if (String.from(value).test(/%$/)) {
          value = winsize.x * Number.from(value) / 100;
        }
        this.base.setStyle('right', window.getSize().x - value + 1);
        return value;
      }
    },
    restrains: {
      value: {
        top: false,
        left: false,
        right: false,
        bottom: false
      }
    },
    bottom: {
      setter: function(value) {
        if (String.from(value).test(/%$/)) {
          value = window.getSize().y * Number.from(value) / 100;
        }
        this.base.setStyle('bottom', window.getSize().y - value);
        return value;
      }
    },
    content: {
      value: null,
      setter: function(newVal, oldVal) {
        this.removeChild(oldVal);
        this.addChild(newVal, 'top');
        return newVal;
      }
    }
  },
  resize: function() {
    var horizpercent, vertpercent, winsize;
    winsize = window.getSize();
    horizpercent = winsize.x / this.windowSize.x;
    vertpercent = winsize.y / this.windowSize.y;
    this.windowSize = winsize;
    this.set('right', Math.floor(this.right * horizpercent));
    this.set('left', Math.floor(this.left * horizpercent));
    this.set('top', Math.floor(this.top * vertpercent));
    return this.set('bottom', Math.floor(this.bottom * vertpercent));
  },
  update: function() {
    var width;
    width = this.base.getSize().x - 10;
    if (this.slider.base.isVisible()) {
      width -= 20;
    }
    this.children.each((function(child) {
      return child.set('size', width);
    }).bind(this));
    this.slider.set('size', this.base.getSize().y - 60);
    if (this.base.getSize().y < this.base.getScrollSize().y) {
      return this.slider.show();
    } else {
      return this.slider.hide();
    }
  },
  create: function() {
    this.windowSize = window.getSize();
    this.addEvent('rightChange', function(o) {
      var a;
      a = this.hooks.right;
      if (a != null) {
        if (a.mod != null) {
          a.mod.each(function(item) {
            return item.set('right', o.newVal);
          });
        }
        if (a.opp != null) {
          return a.opp.each(function(item) {
            return item.set('left', o.newVal);
          });
        }
      }
    });
    this.addEvent('topChange', function(o) {
      var a;
      a = this.hooks.top;
      if (a != null) {
        if (a.mod != null) {
          a.mod.each(function(item) {
            return item.set('top', o.newVal);
          });
        }
        if (a.opp != null) {
          return a.opp.each(function(item) {
            return item.set('bottom', o.newVal);
          });
        }
      }
    });
    this.addEvent('bottomChange', function(o) {
      var a;
      a = this.hooks.bottom;
      if (a != null) {
        if (a.mod != null) {
          a.mod.each(function(item) {
            return item.set('bottom', o.newVal);
          });
        }
        if (a.opp != null) {
          return a.opp.each(function(item) {
            return item.set('top', o.newVal);
          });
        }
      }
    });
    this.addEvent('leftChange', function(o) {
      var a;
      a = this.hooks.left;
      if (a != null) {
        if (a.mod != null) {
          a.mod.each(function(item) {
            return item.set('left', o.newVal);
          });
        }
        if (a.opp != null) {
          return a.opp.each(function(item) {
            return item.set('right', o.newVal);
          });
        }
      }
    });
    this.hooks = {};
    this.slider = new Core.Slider({
      steps: 100,
      mode: 'vertical'
    });
    this.toolbar = new Blender.Toolbar();
    this.toolbar.select.addEvent('change', (function(e) {
      return this.fireEvent('content-change', e);
    }).bind(this));
    this.base.adopt(this.slider, this.toolbar);
    this.position = {
      x: 0,
      y: 0
    };
    this.size = {
      w: 0,
      h: 0
    };
    this.topLeftCorner = new Blender.Corner({
      "class": 'topleft'
    });
    this.topLeftCorner.addEvent('directionChange', (function(dir, e) {
      e.stop();
      if (e.control) {
        if (dir === 'left' || dir === 'right') {
          this.fireEvent('split', [this, 'horizontal']);
        }
        if (dir === 'bottom' || dir === 'top') {
          return this.fireEvent('split', [this, 'vertical']);
        }
      } else {
        if ((dir === 'bottom' || dir === 'top') && !this.restrains.top) {
          this.drag.startpos = {
            y: Number.from(this.base.getStyle('top'))
          };
          this.drag.options.modifiers = {
            x: null,
            y: 'top'
          };
          this.drag.options.invert = true;
          this.drag.start(e);
        }
        if ((dir === 'left' || dir === 'right') && !this.restrains.right) {
          this.drag.startpos = {
            x: Number.from(this.get('right'))
          };
          this.drag.options.modifiers = {
            x: 'right',
            y: null
          };
          this.drag.options.invert = true;
          return this.drag.start(e);
        }
      }
    }).bind(this));
    this.bottomRightCorner = new Blender.Corner({
      "class": 'bottomleft'
    });
    this.bottomRightCorner.addEvent('directionChange', (function(dir, e) {
      if ((dir === 'bottom' || dir === 'top') && !this.restrains.bottom) {
        this.drag.startpos = {
          y: Number.from(this.get('bottom'))
        };
        this.drag.options.modifiers = {
          x: null,
          y: 'bottom'
        };
        this.drag.options.invert = true;
        this.drag.start(e);
      }
      if ((dir === 'left' || dir === 'right') && !this.restrains.left) {
        this.drag.startpos = {
          x: Number.from(this.base.getStyle('left'))
        };
        this.drag.options.modifiers = {
          x: 'left',
          y: null
        };
        this.drag.options.invert = true;
        return this.drag.start(e);
      }
    }).bind(this));
    this.adoptChildren(this.topLeftCorner, this.bottomRightCorner);
    this.drag = new Drag(this.base, {
      modifiers: {
        x: '',
        y: ''
      },
      style: false
    });
    this.drag.detach();
    return this.drag.addEvent('drag', (function(el, e) {
      var offset, posx, posy;
      if (this.drag.options.modifiers.x != null) {
        offset = this.drag.mouse.start.x - this.drag.mouse.now.x;
        if (this.drag.options.invert) {
          offset = -offset;
        }
        posx = offset + this.drag.startpos.x;
        this.set(this.drag.options.modifiers.x, posx > 0 ? posx : 0);
      }
      if (this.drag.options.modifiers.y != null) {
        offset = this.drag.mouse.start.y - this.drag.mouse.now.y;
        if (this.drag.options.invert) {
          offset = -offset;
        }
        posy = offset + this.drag.startpos.y;
        return this.set(this.drag.options.modifiers.y, posy > 0 ? posy : 0);
      }
    }).bind(this));
  },
  check: function() {}
});
