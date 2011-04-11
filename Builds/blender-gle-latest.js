/*
---

name: Element.Extras

description: Extra functions and monkeypatches for moootols Element.

license: MIT-style license.

provides: Element.Extras

...
*/var Blender, Buttons, Core, Data, Dialog, Forms, GDotUI, Interfaces, Iterable, Lattice, Layout, Pickers, UnitList, checkForKey, mergeOneNew;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
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
  Number.implement({
    inRange: function(center, range) {
      if ((center - range < this && this < center + range)) {
        return true;
      } else {
        return false;
      }
    }
  });
  return Number.eval = function(string, size) {
    return Number.from(eval(String.from(string).replace(/(\d*)\%/g, function(match, str) {
      return (Number.from(str) / 100) * size;
    })));
  };
})();
(function() {
  return Color.implement({
    type: 'hex',
    alpha: 100,
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
          return String.from("hsl(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%)");
        case "hsla":
          this.hsl = this.hsvToHsl();
          return String.from("hsla(" + this.hsl[0] + ", " + (Math.round(this.hsl[1])) + "%, " + (Math.round(this.hsl[2])) + "%, " + (this.alpha / 100) + ")");
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
    replaceClass: function(newClass, oldClass) {
      this.removeClass(oldClass);
      return this.addClass(newClass);
    },
    oldGrab: Element.prototype.grab,
    oldInject: Element.prototype.inject,
    oldAdopt: Element.prototype.adopt,
    oldPosition: Element.prototype.position,
    position: function(options) {
      var asize, ofa, op, position, size, winscroll, winsize;
      if (options.relativeTo !== void 0) {
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
      } else {
        options.relativeTo = document.body;
        options.position = {
          x: 'center',
          y: 'center'
        };
        if (typeOf(options.offset !== 'object')) {
          options.offset = {
            x: 0,
            y: 0
          };
        }
      }
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
*/
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
mergeOneNew = function(source, key, current) {
  switch (typeOf(current)) {
    case 'object':
      if (typeOf(source[key]) === 'object') {
        Object.mergeNew(source[key], current);
      } else {
        source[key] = Object.clone(current);
      }
      break;
    case 'array':
      source[key] = current.clone();
      break;
    case 'function':
      current.prototype.parent = source[key];
      source[key] = current;
      break;
    default:
      source[key] = current;
  }
  return source;
};
Object.extend({
  mergeNew: function(source, k, v) {
    var i, object, _ref;
    if (typeOf(k) === 'string') {
      return mergeOneNew(source, k, v);
    }
    for (i = 1, _ref = arguments.length - 1; (1 <= _ref ? i <= _ref : i >= _ref); (1 <= _ref ? i += 1 : i -= 1)) {
      object = arguments[i];
      Object.each(object, function(value, key) {
        return mergeOneNew(source, key, value);
      });
    }
    return source;
  }
});
Class.Mutators.Attributes = function(attributes) {
  var $getter, $setter;
  $setter = attributes.$setter;
  $getter = attributes.$getter;
  if (this.prototype.$attributes) {
    attributes = Object.mergeNew(this.prototype.$attributes, attributes);
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
              newVal = attr.setter.call(this, value, oldVal, attr.setter);
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
GDotUI.selectors = (function() {
  var selectors;
  selectors = {};
  Array.from(document.styleSheets).each(function(stylesheet) {
    try {
      if (stylesheet.cssRules != null) {
        return Array.from(stylesheet.cssRules).each(function(rule) {
          selectors[rule.selectorText] = {};
          return Array.from(rule.style).each(function(style) {
            return selectors[rule.selectorText][style] = rule.style.getPropertyValue(style);
          });
        });
      }
    } catch (_e) {}
  });
  return selectors;
})();
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
Lattice = {};
Lattice.Elements = [];
Lattice.changePrefix = function(newPrefix) {
  this.Elements.each(__bind(function(el) {
    var a, cls;
    a = el["class"].split('-');
    cls = a.erase(a[0]).join('-');
    this.Prefix = newPrefix;
    return el.set('class', this.buildClass(cls));
  }, this));
  return null;
};
Lattice.Prefix = 'blender';
Lattice.buildClass = function(cls) {
  return Lattice.Prefix + "-" + cls;
};
Core.Abstract = new Class({
  Implements: [Events, Interfaces.Mux],
  Attributes: {
    "class": {
      setter: function(value, old) {
        value = String.from(value);
        this.base.replaceClass(value, old);
        return value;
      }
    }
  },
  getSize: function() {
    var comp;
    comp = this.base.getComputedSize({
      styles: ['padding', 'border', 'margin']
    });
    return {
      x: comp.totalWidth,
      y: comp.totalHeight
    };
  },
  initialize: function(attributes) {
    this.base = new Element('div');
    this.base.addEvent('addedToDom', this.ready.bind(this));
    this.mux();
    this.create();
    this.setAttributes(attributes);
    Lattice.Elements.push(this);
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
    return children.each(function(child) {
      return this.addChild(child);
    }, this);
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
    this.children.each(function(child) {
      return document.id(child).dispose();
    });
    return this.children.empty();
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
    return this.addAttributes({
      enabled: {
        value: true,
        setter: function(value) {
          if (value) {
            if (this.children != null) {
              this.children.each(function(item) {
                if (item.enable != null) {
                  return item.set('enabled', true);
                }
              });
            }
            this.base.removeClass('disabled');
          } else {
            if (this.children != null) {
              this.children.each(function(item) {
                if (item.disable != null) {
                  return item.set('enabled', false);
                }
              });
            }
            this.base.addClass('disabled');
          }
          return value;
        }
      }
    });
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
          pos: false
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

name: Interfaces.Size

description: Size minsize from css....

license: MIT-style license.

provides: Interfaces.Size

requires: [GDotUI]
...
*/
Interfaces.Size = new Class({
  _$Size: function() {
    if (GDotUI.selectors["." + (this.get('class'))]) {
      this.size = Number.from(GDotUI.selectors["." + (this.get('class'))]['width']);
    } else {
      this.size = 0;
    }
    if (GDotUI.selectors["." + (this.get('class'))]) {
      this.minSize = Number.from(GDotUI.selectors["." + (this.get('class'))]['min-width']);
    } else {
      this.minSize = 0;
    }
    this.addAttribute('minSize', {
      value: null,
      setter: function(value, old) {
        this.base.setStyle('min-width', value);
        if (this.size < value) {
          this.set('size', value);
        }
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

name: Forms.Input

description: Input elements for Forms.

license: MIT-style license.

requires: GDotUI

provides: Forms.Input

...
*/
Forms.Input = new Class({
  Implements: [Events, Options],
  options: {
    type: '',
    name: ''
  },
  initialize: function(options) {
    var select, tg;
    this.setOptions(options);
    if (this.options.type === 'text' || this.options.type === 'password' || this.options.type === 'button') {
      this.base = new Element('input', {
        type: this.options.type,
        name: this.options.name
      });
    }
    if (this.options.type === 'checkbox') {
      tg = new Core.Toggler();
      tg.base.setAttribute('name', this.options.name);
      tg.base.setAttribute('type', 'checkbox');
      tg.set('checked', this.options.checked || false);
      this.base = tg.base;
    }
    if (this.options.type === "textarea") {
      this.base = new Element('textarea', {
        name: this.options.name
      });
    }
    if (this.options.type === "select") {
      select = new Data.Select({
        "default": this.options.name
      });
      select.base.setAttribute('name', this.options.name);
      select.base.setAttribute('type', 'select');
      this.options.options.each((function(item) {
        return select.addItem(new Iterable.ListItem({
          label: item.label
        }));
      }).bind(this));
      select.addEvent('change', function(v) {
        return this.base.set('value', v);
      });
      this.base = select.base;
    }
    if (this.options.type === "radio") {
      this.base = new Element('div');
      this.options.options.each((function(item, i) {
        var input, label;
        label = new Element('label', {
          'text': item.label
        });
        input = new Element('input', {
          type: 'radio',
          name: this.options.name,
          value: item.value
        });
        return this.base.adopt(label, input);
      }).bind(this));
    }
    if (this.options.validate != null) {
      $splat(this.options.validate).each((function(val) {
        if (this.options.type !== "radio") {
          return this.base.addClass(val);
        }
      }).bind(this));
    }
    return this;
  },
  toElement: function() {
    return this.base;
  }
});
/*
---

name: Forms.Field

description: Field Element for Forms.Fieldset.

license: MIT-style license.

requires:
  - GDotUI
  - Forms.Input

provides: Forms.Field

...
*/
Forms.Field = new Class({
  Implements: [Events, Options],
  Attributes: {
    structure: {
      readOnly: true,
      value: GDotUI.Theme.Forms.Field.struct
    }
  },
  initialize: function(options) {
    var h;
    this.setOptions(options);
    h = new Hash(this.get('structure'));
    return h.each((function(value, key) {
      this.base = new Element(key);
      return this.create(value, this.base);
    }).bind(this));
  },
  create: function(item, parent) {
    var data, el, key, _results;
    if (!(parent != null)) {
      return null;
    } else {
      switch (typeOf(item)) {
        case "object":
          _results = [];
          for (key in item) {
            data = new Hash(item).get(key);
            if (key === 'input') {
              el = new Forms.Input(this.options);
            } else if (key === 'label') {
              el = new Element('label', {
                'text': this.options.label
              });
            } else {
              el = new Element(key);
            }
            parent.grab(el);
            _results.push(this.create(data, el));
          }
          return _results;
      }
    }
  },
  toElement: function() {
    return this.base;
  }
});
/*
---

name: Forms.Fieldset

description: Fieldset for Forms.Form.

license: MIT-style license.

requires: [Core.Abstract, Forms.Field, GDotUI]

provides: Forms.Fieldset

...
*/
Forms.Fieldset = new Class({
  Implements: [Events, Options],
  options: {
    name: '',
    inputs: []
  },
  initialize: function(options) {
    this.setOptions(options);
    this.base = new Element('fieldset');
    this.legend = new Element('legend', {
      text: this.options.name
    });
    this.base.grab(this.legend);
    this.options.inputs.each((function(item) {
      var input;
      input = new Forms.Field(item);
      this.inputs.push(input);
      return this.base.grab(input);
    }).bind(this));
    return this;
  },
  toElement: function() {
    return this.base;
  }
});
/*
---

name: Forms.Form

description: Class for creating forms from javascript objects.

license: MIT-style license.

requires: [Core.Abstract, Forms.Fieldset, GDotUI]

provides: Forms.Form

...
*/
Forms.Form = new Class({
  Extends: Core.Abstract,
  Implements: Options,
  Binds: ['success', 'faliure'],
  options: {
    data: {}
  },
  initialize: function(options) {
    this.fieldsets = [];
    this.setOptions(options);
    return this.parent(options);
  },
  create: function() {
    delete this.base;
    this.base = new Element('form');
    if (this.options.data != null) {
      this.options.data.each((function(fs) {
        return this.addFieldset(new Forms.Fieldset(fs));
      }).bind(this));
    }
    this.extra = this.options.extra;
    this.useRequest = this.options.useRequest;
    if (this.useRequest) {
      this.request = new Request.JSON({
        url: this.options.action,
        resetForm: false,
        method: this.options.method
      });
      this.request.addEvent('success', this.success);
      this.request.addEvent('faliure', this.faliure);
    } else {
      this.base.set('action', this.options.action);
      this.base.set('method', this.options.method);
    }
    this.submit = new Core.Button({
      label: this.options.submit
    });
    this.base.grab(this.submit);
    this.validator = new Form.Validator(this.base, {
      serial: false
    });
    this.validator.start();
    return this.submit.addEvent('click', (function() {
      if (this.validator.validate()) {
        if (this.useRequest) {
          return this.send();
        } else {
          return this.fireEvent('passed', this.geatherdata());
        }
      } else {
        return this.fireEvent('failed', {
          message: 'Validation failed'
        });
      }
    }).bindWithEvent(this));
  },
  addFieldset: function(fieldset) {
    if (this.fieldsets.indexOf(fieldset) === -1) {
      this.fieldsets.push(fieldset);
      return this.base.grab(fieldset);
    }
  },
  geatherdata: function() {
    var data;
    data = {};
    this.base.getElements('div[type=select], input[type=text], input[type=password], textarea, input[type=radio]:checked, input[type=checkbox]:checked').each(function(item) {
      return data[item.get('name')] = item.get('type') === "checkbox" ? true : item.get('value');
    });
    return data;
  },
  send: function() {
    return this.request.send({
      data: $extend(this.geatherdata(), this.extra)
    });
  },
  success: function(data) {
    return this.fireEvent('success', data);
  },
  faliure: function() {
    return this.fireEvent('failed', {
      message: 'Request error!'
    });
  }
});
/*
---

name: Core.Checkbox

description: Blender style checkboxes

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Core.Checkbox

...
*/
Core.Checkbox = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('checkbox')
    },
    state: {
      value: true,
      setter: function(value, old) {
        if (value) {
          this.base.addClass('checked');
        } else {
          this.base.removeClass('checked');
        }
        if (value !== old) {
          this.fireEvent('invoked', [this, value]);
        }
        return value;
      }
    },
    label: {
      value: '',
      setter: function(value) {
        this.textNode.textContent = value;
        return value;
      }
    }
  },
  create: function() {
    this.sign = new Element('div');
    this.sign.addClass("" + (this.get('class')) + "-sign");
    this.textNode = document.createTextNode('');
    this.base.adopt(this.sign, this.textNode);
    return this.base.addEvent('click', __bind(function() {
      if (this.enabled) {
        if (this.state) {
          return this.set('state', false);
        } else {
          return this.set('state', true);
        }
      }
    }, this));
  }
});
/*
---

name: Core.Icon

description: Generic icon element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled

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
      value: Lattice.buildClass('icon')
    }
  },
  create: function() {
    return this.base.addEvent('click', __bind(function(e) {
      if (this.enabled) {
        return this.fireEvent('invoked', [this, e]);
      }
    }, this));
  }
});
/*
---

name: Core.IconGroup

description: Icon group with 5 types of layout.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled

provides: Core.IconGroup

todo: Circular center position and size
...
*/
Core.IconGroup = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Children, Interfaces.Controls, Interfaces.Enabled],
  Binds: ['delegate'],
  Attributes: {
    mode: {
      value: "horizontal",
      validator: function(value) {
        if (['horizontal', 'vertical', 'circular', 'grid', 'linear'].indexOf(value) > -1) {
          return true;
        } else {
          return false;
        }
      }
    },
    spacing: {
      value: {
        x: 0,
        y: 0
      },
      validator: function(value) {
        if (typeOf(value) === 'object') {
          if ((value.x != null) && (value.y != null)) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    },
    startAngle: {
      value: 0,
      setter: function(value) {
        return Number.from(value);
      },
      validator: function(value) {
        var a;
        if ((a = Number.from(value)) != null) {
          return a >= 0 && a <= 360;
        } else {
          return false;
        }
      }
    },
    radius: {
      value: 0,
      setter: function(value) {
        return Number.from(value);
      },
      validator: function(value) {
        var a;
        return (a = Number.from(value)) != null;
      }
    },
    degree: {
      value: 360,
      setter: function(value) {
        return Number.from(value);
      },
      validator: function(value) {
        var a;
        if ((a = Number.from(value)) != null) {
          return a >= 0 && a <= 360;
        } else {
          return false;
        }
      }
    },
    rows: {
      value: 1,
      setter: function(value) {
        return Number.from(value);
      },
      validator: function(value) {
        var a;
        if ((a = Number.from(value)) != null) {
          return a > 0;
        } else {
          return false;
        }
      }
    },
    columns: {
      value: 1,
      setter: function(value) {
        return Number.from(value);
      },
      validator: function(value) {
        var a;
        if ((a = Number.from(value)) != null) {
          return a > 0;
        } else {
          return false;
        }
      }
    },
    "class": {
      value: 'blender-icon-group'
    }
  },
  create: function() {
    return this.base.setStyle('position', 'relative');
  },
  delegate: function() {
    return this.fireEvent('invoked', arguments);
  },
  addIcon: function(icon) {
    if (!this.hasChild(icon)) {
      icon.addEvent('invoked', this.delegate);
      this.addChild(icon);
      return this.update();
    }
  },
  removeIcon: function(icon) {
    if (this.hasChild(icon)) {
      icon.removeEvent('invoked', this.delegate);
      this.removeChild(icon);
      return this.update();
    }
  },
  ready: function() {
    return this.update();
  },
  update: function() {
    var columns, fok, icpos, ker, n, radius, rows, spacing, startAngle, x, y;
    if (this.children.length > 0 && (this.mode != null)) {
      x = 0;
      y = 0;
      this.size = {
        x: 0,
        y: 0
      };
      spacing = this.spacing;
      switch (this.mode) {
        case 'grid':
          if ((this.rows != null) && (this.columns != null)) {
            if (this.rows < this.columns) {
              rows = null;
              columns = this.columns;
            } else {
              columns = null;
              rows = this.rows;
            }
          }
          icpos = this.children.map(__bind(function(item, i) {
            if (rows != null) {
              if (i % rows === 0) {
                y = 0;
                x = i === 0 ? x : x + item.base.getSize().x + spacing.x;
              } else {
                y = i === 0 ? y : y + item.base.getSize().y + spacing.y;
              }
            }
            if (columns != null) {
              if (i % columns === 0) {
                x = 0;
                y = i === 0 ? y : y + item.base.getSize().y + spacing.y;
              } else {
                x = i === 0 ? x : x + item.base.getSize().x + spacing.x;
              }
            }
            this.size.x = x + item.base.getSize().x;
            this.size.y = y + item.base.getSize().y;
            return {
              x: x,
              y: y
            };
          }, this));
          break;
        case 'linear':
          icpos = this.children.map(__bind(function(item, i) {
            x = i === 0 ? x + x : x + spacing.x + item.base.getSize().x;
            y = i === 0 ? y + y : y + spacing.y + item.base.getSize().y;
            this.size.x = x + item.base.getSize().x;
            this.size.y = y + item.base.getSize().y;
            return {
              x: x,
              y: y
            };
          }, this));
          break;
        case 'horizontal':
          icpos = this.children.map(__bind(function(item, i) {
            x = i === 0 ? x + x : x + item.base.getSize().x + spacing.x;
            y = i === 0 ? y : y;
            this.size.x = x + item.base.getSize().x;
            this.size.y = item.base.getSize().y;
            return {
              x: x,
              y: y
            };
          }, this));
          break;
        case 'vertical':
          icpos = this.children.map(__bind(function(item, i) {
            x = i === 0 ? x : x;
            y = i === 0 ? y + y : y + item.base.getSize().y + spacing.y;
            this.size.x = item.base.getSize().x;
            this.size.y = y + item.base.getSize().y;
            return {
              x: x,
              y: y
            };
          }, this));
          break;
        case 'circular':
          n = this.children.length;
          radius = this.radius;
          startAngle = this.startAngle;
          ker = 2 * this.radius * Math.PI;
          fok = this.degree / n;
          icpos = this.children.map(function(item, i) {
            var foks;
            if (i === 0) {
              foks = startAngle * (Math.PI / 180);
              x = Math.round(radius * Math.sin(foks)) + radius / 2 + item.base.getSize().x;
              y = -Math.round(radius * Math.cos(foks)) + radius / 2 + item.base.getSize().y;
            } else {
              x = Math.round(radius * Math.sin(((fok * i) + startAngle) * (Math.PI / 180))) + radius / 2 + item.base.getSize().x;
              y = -Math.round(radius * Math.cos(((fok * i) + startAngle) * (Math.PI / 180))) + radius / 2 + item.base.getSize().y;
            }
            return {
              x: x,
              y: y
            };
          });
      }
      this.base.setStyles({
        width: this.size.x,
        height: this.size.y
      });
      return this.children.each(function(item, i) {
        item.base.setStyle('top', icpos[i].y);
        item.base.setStyle('left', icpos[i].x);
        return item.base.setStyle('position', 'absolute');
      });
    }
  }
});
/*
---

name: Core.Tip

description: Tip class

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract

provides: Core.Tip

...
*/
Core.Tip = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Enabled,
  Binds: ['enter', 'leave'],
  Attributes: {
    "class": {
      value: Lattice.buildClass('tip')
    },
    label: {
      value: '',
      setter: function(value) {
        return this.base.set('html', value);
      }
    },
    zindex: {
      value: 1,
      setter: function(value) {
        return this.base.setStyle('z-index', value);
      }
    },
    delay: {
      value: 0
    },
    location: {
      value: {
        x: 'center',
        y: 'center'
      }
    },
    offset: {
      value: 0
    }
  },
  create: function() {
    return this.base.setStyle('position', 'absolute');
  },
  attach: function(item) {
    if (this.attachedTo != null) {
      this.detach();
    }
    this.attachedTo = document.id(item);
    this.attachedTo.addEvent('mouseenter', this.enter);
    return this.attachedTo.addEvent('mouseleave', this.leave);
  },
  detach: function() {
    this.attachedTo.removeEvent('mouseenter', this.enter);
    this.attachedTo.removeEvent('mouseleave', this.leave);
    return this.attachedTo = null;
  },
  enter: function() {
    if (this.enabled) {
      this.over = true;
      return this.id = (function() {
        if (this.over) {
          return this.show();
        }
      }).bind(this).delay(this.delay);
    }
  },
  leave: function() {
    if (this.enabled) {
      if (this.id != null) {
        clearTimeout(this.id);
        this.id = null;
      }
      this.over = false;
      return this.hide();
    }
  },
  ready: function() {
    if (this.attachedTo != null) {
      return this.base.position({
        relativeTo: this.attachedTo,
        position: this.location,
        offset: this.offset
      });
    }
  },
  hide: function() {
    return this.base.dispose();
  },
  show: function() {
    return document.getElement('body').grab(this.base);
  }
});
/*
---

name: Core.Slider

description: Slider element for other elements.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled

provides: Core.Slider

...
*/
Core.Slider = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Controls, Interfaces.Enabled],
  Attributes: {
    "class": {
      value: Lattice.buildClass('slider')
    },
    bar: {
      value: 'progress',
      setter: function(value, old) {
        this.progress.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
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
            console.log("." + this["class"] + ".horizontal");
            this.minSize = Number.from(GDotUI.selectors["." + this["class"] + ".horizontal"]['min-width']);
            this.modifier = 'width';
            this.drag.options.modifiers = {
              x: 'width',
              y: ''
            };
            this.drag.options.invert = false;
            if (!(this.size != null)) {
              size = Number.from(GDotUI.selectors["." + this["class"] + ".horizontal"]['width']);
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
            this.minSize = Number.from(GDotUI.selectors["." + this["class"] + ".vertical"]['min-height']);
            this.modifier = 'height';
            this.drag.options.modifiers = {
              x: '',
              y: 'height'
            };
            this.drag.options.invert = true;
            if (!(this.size != null)) {
              size = Number.from(GDotUI.selectors["." + this["class"] + ".vertical"]['height']);
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
    value: {
      value: 0,
      setter: function(value) {
        var percent;
        value = Number.from(value);
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
      },
      getter: function() {
        if (this.reset) {
          return this.value;
        } else {
          return Number.from(this.progress.getStyle(this.modifier)) / this.size * this.steps;
        }
      }
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
    }
  },
  onDrag: function(el, e) {
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
  },
  create: function() {
    this.progress = new Element("div");
    this.base.adopt(this.progress);
    this.drag = new Drag(this.progress, {
      handle: this.base
    });
    this.drag.addEvent('beforeStart', __bind(function(el, e) {
      this.lastpos = Math.round((Number.from(el.getStyle(this.modifier)) / this.size) * this.steps);
      if (!this.enabled) {
        return this.disabledTop = el.getStyle(this.modifier);
      }
    }, this));
    this.drag.addEvent('complete', __bind(function(el, e) {
      if (this.reset) {
        if (this.enabled) {
          el.setStyle(this.modifier, this.size / 2 + "px");
        }
      }
      return this.fireEvent('complete');
    }, this));
    this.drag.addEvent('drag', this.onDrag.bind(this));
    return this.base.addEvent('mousewheel', __bind(function(e) {
      e.stop();
      if (this.enabled) {
        this.set('value', this.value + Number.from(e.wheel));
        return this.fireEvent('step', this.value);
      }
    }, this));
  }
});
/*
---

name: Core.Scrollbar

description: Slider element for other elements.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - Core.Slider

provides: Core.Scrollbar

...
*/
Core.Scrollbar = new Class({
  Extends: Core.Slider,
  Attributes: {
    mode: {
      setter: function(value, old, self) {
        self.prototype.parent.call(this, value, old);
        switch (value) {
          case 'horizontal':
            this.smodif = 'left';
            this.drag.options.modifiers = {
              x: 'left',
              y: ''
            };
            break;
          case 'vertical':
            this.smodif = 'top';
            this.drag.options.modifiers = {
              x: '',
              y: 'top'
            };
            this.drag.options.invert = false;
        }
        return value;
      }
    },
    value: {
      getter: function() {
        var width;
        if (this.reset) {
          return this.value;
        } else {
          width = this.size - this.progressSize;
          return Number.from(this.progress.getStyle(this.smodif)) / width * this.steps;
        }
      },
      setter: function(value) {
        var percent, width;
        value = Number.from(value);
        width = this.size - this.progressSize;
        if (!this.reset) {
          percent = Math.round((value / this.steps) * 100);
          if (value < 0) {
            this.progress.setStyle(this.smodif, 0);
            value = 0;
          } else if (value > this.steps) {
            this.progress.setStyle(this.smodif, width);
            value = this.steps;
          } else if (!(value < 0) && !(value > this.steps)) {
            this.progress.setStyle(this.smodif, (percent / 100) * width);
          }
        }
        return value;
      }
    },
    size: {
      setter: function(value, old) {
        if (!(value != null)) {
          value = old;
        } else {
          value = Number.from(value);
        }
        if (this.minSize > value) {
          value = this.minSize;
        }
        this.base.setStyle(this.modifier, value);
        this.progress.setStyle(this.modifier, value * 0.7);
        this.progressSize = value * 0.7;
        return value;
      }
    }
  },
  create: function() {
    return this.parent();
  },
  onDrag: function(el, e) {
    var left, width;
    if (this.enabled) {
      left = Number.from(this.progress.getStyle(this.smodif));
      width = this.size - this.progressSize;
      if (left < this.size - this.progressSize) {
        this.value = left / width * this.steps;
      } else {
        el.setStyle(this.smodif, this.size - this.progressSize);
        this.value = this.steps;
      }
      if (left < 0) {
        el.setStyle(this.smodif, 0);
        this.value = 0;
      }
      return this.fireEvent('step', Math.round(this.value));
    } else {
      return this.set('value', this.value);
    }
  }
});
/*
---

name: Buttons.Abstract

description: Basic button element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Buttons.Abstract

...
*/
Buttons = {};
Buttons.Abstract = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls, Interfaces.Size],
  Attributes: {
    label: {
      value: '',
      setter: function(value) {
        this.base.set('text', value);
        return value;
      }
    },
    "class": {
      value: Lattice.buildClass('button')
    }
  },
  create: function() {
    return this.base.addEvent('click', __bind(function(e) {
      if (this.enabled) {
        return this.fireEvent('invoked', [this, e]);
      }
    }, this));
  }
});
/*
---

name: Buttons.Key

description: Button for shortcut editing.

license: MIT-style license.

requires:
  - Buttons.Abstract

provides: Buttons.Key

...
*/
Buttons.Key = new Class({
  Extends: Buttons.Abstract,
  Attributes: {
    "class": {
      value: Lattice.buildClass('button-key')
    }
  },
  getShortcut: function(e) {
    var modifiers, specialKey;
    this.specialMap = {
      '~': '`',
      '!': '1',
      '@': '2',
      '#': '3',
      '$': '4',
      '%': '5',
      '^': '6',
      '&': '7',
      '*': '8',
      '(': '9',
      ')': '0',
      '_': '-',
      '+': '=',
      '{': '[',
      '}': ']',
      '\\': '|',
      ':': ';',
      '"': '\'',
      '<': ',',
      '>': '.',
      '?': '/'
    };
    modifiers = '';
    if (e.control) {
      modifiers += 'ctrl ';
    }
    if (event.meta) {
      modifiers += 'meta ';
    }
    if (e.shift) {
      specialKey = this.specialMap[String.fromCharCode(e.code)];
      if (specialKey != null) {
        e.key = specialKey;
      }
      modifiers += 'shift ';
    }
    if (e.alt) {
      modifiers += 'alt ';
    }
    return modifiers + e.key;
  },
  create: function() {
    var stop;
    stop = function(e) {
      return e.stop();
    };
    return this.base.addEvent('click', __bind(function(e) {
      this.set('label', 'Press any key!');
      this.base.addClass('active');
      window.addEvent('keydown', stop);
      return window.addEvent('keyup:once', __bind(function(e) {
        var shortcut;
        this.base.removeClass('active');
        shortcut = this.getShortcut(e).toUpperCase();
        if (shortcut !== "ESC") {
          this.set('label', shortcut);
          this.fireEvent('invoked', [this, shortcut]);
        }
        return window.removeEvent('keydown', stop);
      }, this));
    }, this));
  }
});
/*
---

name: Core.Picker

description: Data picker class.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled

provides: Core.Picker
...
*/
Core.Picker = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Children],
  Binds: ['show', 'hide', 'delegate'],
  Attributes: {
    "class": {
      value: Lattice.buildClass('picker')
    },
    offset: {
      value: 0,
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
      value: 'picking'
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
      return el.addEvent('click', this.show);
    }
  },
  detach: function() {
    if (this.attachedTo != null) {
      this.attachedTo.removeEvent('click', this.show);
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

name: Iterable.List

description: List element, with editing and sorting.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.List

requires:
  - G.UI/GDotUI
...
*/
Iterable.List = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Children, Interfaces.Size],
  Attributes: {
    "class": {
      value: 'blender-list'
    },
    selectedClass: {
      value: 'blender-list-selected'
    },
    selected: {
      getter: function() {
        return this.children.filter((function(item) {
          if (item.base.hasClass(this.selectedClass)) {
            return true;
          } else {
            return false;
          }
        }).bind(this))[0];
      },
      setter: function(value, old) {
        if (old) {
          old.base.removeClass(this.selectedClass);
        }
        if (value != null) {
          value.base.addClass(this.selectedClass);
        }
        return value;
      }
    }
  },
  getItemFromLabel: function(label) {
    var filtered;
    filtered = this.children.filter(function(item) {
      if (String.from(item.label).toLowerCase() === String(label).toLowerCase()) {
        return true;
      } else {
        return false;
      }
    });
    return filtered[0];
  },
  addItem: function(li) {
    this.addChild(li);
    li.addEvent('select', __bind(function(item, e) {
      return this.set('selected', item);
    }, this));
    return li.addEvent('invoked', __bind(function(item) {
      return this.fireEvent('invoked', arguments);
    }, this));
  }
});
/*
---

name: Core.Slot

description: iOs style slot control.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - Iterable.List

provides: Core.Slot

todo: horizontal/vertical, interfaces.size etc
...
*/
Core.Slot = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('slot')
    }
  },
  Binds: ['check', 'complete'],
  Delegates: {
    'list': ['addItem', 'removeAll', 'select']
  },
  create: function() {
    this.overlay = new Element('div', {
      'text': ' '
    });
    this.overlay.addClass('over');
    this.list = new Iterable.List();
    this.list.base.addEvent('addedToDom', this.update.bind(this));
    this.list.addEvent('selectedChange', (function(item) {
      this.update();
      return this.fireEvent('change', item.newVal);
    }).bind(this));
    this.base.setStyle('overflow', 'hidden');
    this.base.setStyle('position', 'relative');
    this.list.base.setStyle('position', 'relative');
    this.list.base.setStyle('top', '0');
    this.overlay.setStyles({
      'position': 'absolute',
      'top': 0,
      'left': 0,
      'right': 0,
      'bottom': 0
    });
    this.overlay.addEvent('mousewheel', this.mouseWheel.bind(this));
    this.drag = new Drag(this.list.base, {
      modifiers: {
        x: '',
        y: 'top'
      },
      handle: this.overlay
    });
    this.drag.addEvent('drag', this.check);
    this.drag.addEvent('beforeStart', (function() {
      if (!this.enabled) {
        this.disabledTop = this.list.base.getStyle('top');
      }
      return this.list.base.removeTransition();
    }).bind(this));
    return this.drag.addEvent('complete', (function() {
      this.dragging = false;
      return this.update();
    }).bind(this));
  },
  ready: function() {
    return this.base.adopt(this.list, this.overlay);
  },
  check: function(el, e) {
    var lastDistance, lastOne;
    if (this.enabled) {
      this.dragging = true;
      lastDistance = 1000;
      lastOne = null;
      return this.list.children.each((function(item, i) {
        var distance;
        distance = -item.base.getPosition(this.base).y + this.base.getSize().y / 2;
        if (distance < lastDistance && distance > 0 && distance < this.base.getSize().y / 2) {
          return this.list.set('selected', item);
        }
      }).bind(this));
    } else {
      return el.setStyle('top', this.disabledTop);
    }
  },
  mouseWheel: function(e) {
    var index;
    if (this.enabled) {
      e.stop();
      if (this.list.selected != null) {
        index = this.list.children.indexOf(this.list.selected);
      } else {
        if (e.wheel === 1) {
          index = 0;
        } else {
          index = 1;
        }
      }
      if (index + e.wheel >= 0 && index + e.wheel < this.list.children.length) {
        this.list.set('selected', this.list.children[index + e.wheel]);
      }
      if (index + e.wheel < 0) {
        this.list.set('selected', this.list.children[this.list.children.length - 1]);
      }
      if (index + e.wheel > this.list.children.length - 1) {
        return this.list.set('selected', this.list.children[0]);
      }
    }
  },
  update: function() {
    if (!this.dragging) {
      this.list.base.addTransition();
      if (this.list.selected != null) {
        return this.list.base.setStyle('top', -this.list.selected.base.getPosition(this.list.base).y + this.base.getSize().y / 2 - this.list.selected.base.getSize().y / 2);
      }
    }
  }
});
/*
---

name: Core.Toggler

description: iOs style checkboxes

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Core.Toggler

...
*/
Core.Toggler = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('button-toggle')
    },
    onLabel: {
      value: 'ON',
      setter: function(value) {
        return this.onDiv.set('text', value);
      }
    },
    offLabel: {
      value: 'OFF',
      setter: function(value) {
        return this.offDiv.set('text', value);
      }
    },
    onClass: {
      value: 'on',
      setter: function(value, old) {
        this.onDiv.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    offClass: {
      value: 'off',
      setter: function(value, old) {
        this.offDiv.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    separatorClass: {
      value: 'separator',
      setter: function(value, old) {
        this.separator.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    checked: {
      value: true,
      setter: function(value) {
        this.fireEvent('change', value);
        return value;
      }
    }
  },
  update: function() {
    if (this.size) {
      $$(this.onDiv, this.offDiv, this.separator).setStyles({
        width: this.size / 2
      });
      this.base.setStyle('width', this.size);
    }
    if (this.checked) {
      this.separator.setStyle('left', this.size / 2);
    } else {
      this.separator.setStyle('left', 0);
    }
    return this.offDiv.setStyle('left', this.size / 2);
  },
  create: function() {
    this.base.setStyle('position', 'relative');
    this.onDiv = new Element('div');
    this.offDiv = new Element('div');
    this.separator = new Element('div', {
      html: '&nbsp;'
    });
    this.base.adopt(this.onDiv, this.offDiv, this.separator);
    $$(this.onDiv, this.offDiv, this.separator).setStyles({
      'position': 'absolute',
      'top': 0,
      'left': 0
    });
    return this.base.addEvent('click', __bind(function() {
      if (this.enabled) {
        if (this.checked) {
          return this.set('checked', false);
        } else {
          return this.set('checked', true);
        }
      }
    }, this));
  }
});
/*
---

name: Core.Overlay

description: Overlay for modal dialogs and alike.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Enabled

provides: Core.Overlay

...
*/
Core.Overlay = new Class({
  Extends: Core.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Controls],
  Attributes: {
    "class": {
      value: Lattice.buildClass('overlay')
    },
    zindex: {
      value: 0,
      setter: function(value) {
        this.base.setStyle('z-index', value);
        return value;
      },
      validator: function(value) {
        return Number.from(value) !== null;
      }
    }
  },
  create: function() {
    this.base.setStyles({
      position: "fixed",
      top: 0,
      left: 0,
      right: 0,
      bottom: 0
    });
    return this.hide();
  }
});
/*
---

name: Core.Tab

description: Tab element for Core.Tabs.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract

provides: Core.Tab

...
*/
Core.Tab = new Class({
  Extends: Core.Abstract,
  Attributes: {
    "class": {
      value: Lattice.buildClass('tab')
    },
    label: {
      value: '',
      setter: function(value) {
        this.base.set('text', value);
        return value;
      }
    },
    activeClass: {
      value: 'active'
    }
  },
  create: function() {
    this.base.addEvent('click', __bind(function() {
      return this.fireEvent('activate', this);
    }, this));
    return this.base.adopt(this.label);
  },
  activate: function(event) {
    if (event) {
      this.fireEvent('activated', this);
    }
    return this.base.addClass(this.activeClass);
  },
  deactivate: function(event) {
    if (event) {
      this.fireEvent('deactivated', this);
    }
    return this.base.removeClass(this.activeClass);
  }
});
/*
---

name: Core.Tabs

description: Tab navigation element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - Core.Tab

provides: Core.Tabs

...
*/
Core.Tabs = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Children,
  Binds: ['change'],
  Attributes: {
    "class": {
      value: 'blender-group-tab'
    },
    active: {
      setter: function(value, old) {
        if (!(old != null)) {
          value.activate(false);
        } else {
          if (old !== value) {
            old.deactivate(false);
          }
          value.activate(false);
        }
        return value;
      }
    }
  },
  add: function(tab) {
    if (!this.hasChild(tab)) {
      this.addChild(tab);
      return tab.addEvent('activate', this.change);
    }
  },
  remove: function(tab) {
    if (this.hasChild(tab)) {
      return this.removeChild(tab);
    }
  },
  change: function(tab) {
    if (tab !== this.active) {
      this.set('active', tab);
      return this.fireEvent('change', tab);
    }
  },
  getByLabel: function(label) {
    return (this.children.filter(function(item, i) {
      if (item.label === label) {
        return true;
      } else {
        return false;
      }
    }))[0];
  }
});
/*
---

name: Buttons.Toggle

description: Toggle button 'push' element.

license: MIT-style license.

requires:
  - Buttons.Abstract

provides: Buttons.Toggle

...
*/
Buttons.Toggle = new Class({
  Extends: Buttons.Abstract,
  Attributes: {
    state: {
      value: false,
      setter: function(value, old) {
        if (value) {
          this.base.addClass('pushed');
        } else {
          this.base.removeClass('pushed');
        }
        return value;
      },
      getter: function() {
        return this.base.hasClass('pushed');
      }
    },
    "class": {
      value: Lattice.buildClass('button-push')
    }
  },
  create: function() {
    this.addEvent('stateChange', function() {
      return this.fireEvent('invoked', [this, this.state]);
    });
    return this.base.addEvent('click', __bind(function() {
      if (this.enabled) {
        return this.set('state', this.state ? false : true);
      }
    }, this));
  }
});
/*
---

name: Core.PushGroup

description: PushGroup element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Core.PushGroup
...
*/
Core.PushGroup = new Class({
  Extends: Core.Abstract,
  Binds: ['change'],
  Implements: [Interfaces.Enabled, Interfaces.Children, Interfaces.Size],
  Attributes: {
    "class": {
      value: 'blender-push-group'
    },
    active: {
      setter: function(value, old) {
        if (!(old != null)) {
          value.set('state', true);
        } else {
          if (old !== value) {
            old.set('state', false);
          }
          value.set('state', true);
        }
        return value;
      }
    }
  },
  update: function() {
    var buttonwidth, last;
    buttonwidth = Math.floor(this.size / this.children.length);
    this.children.each(function(btn) {
      return btn.set('size', buttonwidth);
    });
    if (last = this.children.getLast()) {
      return last.set('size', this.size - buttonwidth * (this.children.length - 1));
    }
  },
  change: function(button, value) {
    if (button !== this.active) {
      if (button.state) {
        this.set('active', button);
        return this.fireEvent('change', button);
      }
    }
  },
  emptyItems: function() {
    this.children.each(function(child) {
      console.log(child);
      return child.removeEvents('invoked');
    }, this);
    return this.empty();
  },
  removeItem: function(item) {
    if (this.hasChild(item)) {
      item.removeEvents('invoked');
      this.removeChild(item);
    }
    return this.update();
  },
  addItem: function(item) {
    if (!this.hasChild(item)) {
      item.set('minSize', 0);
      item.addEvent('invoked', this.change);
      this.addChild(item);
    }
    return this.update();
  }
});
/*
---

name: Dialog.Abstract

description: Select Element

license: MIT-style license.

requires:
  - G.UI/Core.Abstract
  - Buttons.Abstract

provides: Dialog.Abstract

...
*/
Dialog.Abstract = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.Size,
  Delegates: {
    picker: ['hide', 'attach']
  },
  Attributes: {
    "class": {
      value: 'dialog-prompt'
    },
    overlay: {
      value: false
    }
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.picker = new Core.Picker();
    return this.overlayEl = new Core.Overlay();
  },
  show: function() {
    this.picker.set('content', this.base);
    this.picker.show(void 0, false);
    if (this.overlay) {
      return document.body.grab(this.overlayEl);
    }
  },
  hide: function(e, force) {
    if (force != null) {
      this.overlayEl.base.dispose();
      this.picker.hide(e, true);
    }
    if (e != null) {
      if (this.base.isVisible() && !this.base.hasChild(e.target) && e.target !== this.base) {
        this.overlayEl.base.dispose();
        return this.picker.hide(e);
      }
    }
  }
});
/*
---

name: Dialog.Prompt

description: Select Element

license: MIT-style license.

requires:
  - G.UI/Core.Abstract
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Prompt

...
*/
Dialog.Prompt = new Class({
  Extends: Dialog.Abstract,
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
  update: function() {
    ({
      update: function() {}
    });
    this.labelDiv.setStyle('width', this.size);
    this.button.set('size', this.size);
    this.input.set('size', this.size);
    return this.base.setStyle('width', 'auto');
  },
  create: function() {
    this.parent();
    this.labelDiv = new Element('div');
    this.input = new Data.Text();
    this.button = new Buttons.Abstract();
    this.base.adopt(this.labelDiv, this.input, this.button);
    return this.button.addEvent('invoked', __bind(function(el, e) {
      this.fireEvent('invoked', this.input.get('value'));
      return this.hide(e, true);
    }, this));
  }
});
/*
---

name: Data.Select

description: Select Element

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - Core.Picker
  - G.UI/Data.Abstract
  - Dialog.Prompt
  - G.UI/Interfaces.Controls
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size
  - Iterable.List

provides: Data.Select

...
*/
Data.Select = new Class({
  Extends: Data.Abstract,
  Implements: [Interfaces.Controls, Interfaces.Enabled, Interfaces.Size, Interfaces.Children],
  Attributes: {
    "class": {
      value: Lattice.buildClass('select')
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
        return this.list.set('selected', this.list.getItemFromLabel(value));
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
      value: 'text',
      setter: function(value, old) {
        this.text.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    removeClass: {
      value: 'remove',
      setter: function(value, old) {
        this.removeIcon.set('class', this["class"] + "-" + value);
        return value;
      }
    },
    addClass: {
      value: 'add',
      setter: function(value, old) {
        this.addIcon.set('class', this["class"] + "-" + value);
        return value;
      }
    },
    listClass: {
      value: 'blender-list',
      setter: function(value) {
        return this.list.set('class', value);
      }
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
      if (item != null) {
        this.text.set('text', item.label);
        this.fireEvent('change', item.label);
      } else {
        this.text.set('text', '');
      }
      return this.picker.hide(null, true);
    }).bind(this));
    return this.update();
  },
  addItem: function(item) {
    return this.list.addItem(item);
  },
  removeItem: function(item) {
    return this.list.removeItem(item);
  }
});
/*
---

name: Data.Text

description: Text data element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - G.UI/Interfaces.Size

provides: Data.Text

...
*/
Data.Text = new Class({
  Extends: Data.Abstract,
  Implements: Interfaces.Size,
  Binds: ['update'],
  Attributes: {
    "class": {
      value: 'blender-textarea'
    },
    value: {
      setter: function(value) {
        this.text.set('value', value);
        return value;
      },
      getter: function() {
        return this.text.get('value');
      }
    }
  },
  update: function() {
    this.fireEvent('change', this.get('value'));
    return this.text.setStyle('width', this.size - 10);
  },
  create: function() {
    this.text = new Element('textarea');
    this.base.grab(this.text);
    return this.text.addEvent('keyup', this.update);
  }
});
/*
---

name: Data.Number

description: Number data element.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Core.Slider

provides: Data.Number

...
*/
Data.Number = new Class({
  Extends: Core.Slider,
  Attributes: {
    "class": {
      value: Lattice.buildClass('number')
    },
    text: {
      value: 'text',
      setter: function(value, old) {
        this.textLabel.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    range: {
      value: GDotUI.Theme.Number.range
    },
    reset: {
      value: GDotUI.Theme.Number.reset
    },
    steps: {
      value: GDotUI.Theme.Number.steps
    },
    label: {
      value: null
    }
  },
  create: function() {
    this.parent();
    this.textLabel = new Element("div");
    this.textLabel.setStyles({
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      top: 0
    });
    this.base.grab(this.textLabel);
    return this.addEvent('step', (function(e) {
      return this.fireEvent('change', e);
    }).bind(this));
  },
  update: function() {
    return this.textLabel.set('text', this.label != null ? this.label + " : " + this.value : this.value);
  }
});
/*
---

name: Data.Color

description: Color data element. ( color picker )

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Number
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Size

provides: Data.Color

...
*/
Data.Color = new Class({
  Extends: Data.Abstract,
  Binds: ['update'],
  Implements: [Interfaces.Enabled, Interfaces.Children, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('color')
    },
    hue: {
      value: 0,
      setter: function(value) {
        this.hueData.set('value', value);
        return value;
      },
      getter: function() {
        return this.hueData.value;
      }
    },
    saturation: {
      value: 0,
      setter: function(value) {
        this.saturationData.set('value', value);
        return value;
      },
      getter: function() {
        return this.saturationData.value;
      }
    },
    lightness: {
      value: 100,
      setter: function(value) {
        this.lightnessData.set('value', value);
        return value;
      },
      getter: function() {
        return this.lightnessData.value;
      }
    },
    alpha: {
      value: 100,
      setter: function(value) {
        this.alphaData.set('value', value);
        return value;
      },
      getter: function() {
        return this.alphaData.value;
      }
    },
    type: {
      value: 'hex',
      setter: function(value) {
        this.col.children.each(function(item) {
          if (item.label === value) {
            return this.col.set('active', item);
          }
        }, this);
        return value;
      },
      getter: function() {
        if (this.col.active != null) {
          return this.col.active.label;
        }
      }
    },
    value: {
      value: new Color('#fff'),
      setter: function(value) {
        console.log(value.hsb[0], value.hsb[1], value.hsb[2]);
        this.set('hue', value.hsb[0]);
        this.set('saturation', value.hsb[1]);
        this.set('lightness', value.hsb[2]);
        this.set('type', value.type);
        return this.set('alpha', value.alpha);
      }
    }
  },
  ready: function() {
    return this.update();
  },
  update: function() {
    var alpha, hue, lightness, ret, saturation, type;
    hue = this.get('hue');
    saturation = this.get('saturation');
    lightness = this.get('lightness');
    type = this.get('type');
    alpha = this.get('alpha');
    if ((hue != null) && (saturation != null) && (lightness != null) && (type != null) && (alpha != null)) {
      ret = $HSB(hue, saturation, lightness);
      ret.setAlpha(alpha);
      ret.setType(type);
      return this.fireEvent('change', new Hash(ret));
    }
  },
  create: function() {
    this.addEvent('sizeChange', __bind(function() {
      this.hueData.set('size', this.size);
      this.saturationData.set('size', this.size);
      this.lightnessData.set('size', this.size);
      this.alphaData.set('size', this.size);
      return this.col.set('size', this.size);
    }, this));
    this.hueData = new Data.Number({
      range: [0, 360],
      reset: false,
      steps: 360,
      label: 'Hue'
    });
    this.saturationData = new Data.Number({
      range: [0, 100],
      reset: false,
      steps: 100,
      label: 'Saturation'
    });
    this.lightnessData = new Data.Number({
      range: [0, 100],
      reset: false,
      steps: 100,
      label: 'Value'
    });
    this.alphaData = new Data.Number({
      range: [0, 100],
      reset: false,
      steps: 100,
      label: 'Alpha'
    });
    this.col = new Core.PushGroup();
    ['rgb', 'rgba', 'hsl', 'hsla', 'hex'].each((function(item) {
      return this.col.addItem(new Buttons.Toggle({
        label: item
      }));
    }).bind(this));
    this.hueData.addEvent('change', this.update);
    this.saturationData.addEvent('change', this.update);
    this.lightnessData.addEvent('change', this.update);
    this.alphaData.addEvent('change', this.update);
    this.col.addEvent('change', this.update);
    return this.adoptChildren(this.hueData, this.saturationData, this.lightnessData, this.alphaData, this.col);
  }
});
/*
---

name: Data.ColorWheel

description: ColorWheel data element. ( color picker )

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Color
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - G.UI/Interfaces.Size

provides: Data.ColorWheel

...
*/
Data.ColorWheel = new Class({
  Extends: Data.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Children, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('color')
    },
    value: {
      setter: function(value) {
        return this.colorData.set('value', value);
      }
    },
    wrapperClass: {
      value: 'wrapper',
      setter: function(value, old) {
        this.wrapper.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    },
    knobClass: {
      value: 'xyknob',
      setter: function(value, old) {
        this.knob.replaceClass("" + this["class"] + "-" + value, "" + this["class"] + "-" + old);
        return value;
      }
    }
  },
  create: function() {
    this.hslacone = $(document.createElement('canvas'));
    this.background = $(document.createElement('canvas'));
    this.wrapper = new Element('div');
    this.knob = new Element('div');
    this.knob.setStyles({
      'position': 'absolute',
      'z-index': 1
    });
    this.colorData = new Data.Color();
    this.colorData.addEvent('change', (function(e) {
      return this.fireEvent('change', e);
    }).bind(this));
    this.base.adopt(this.wrapper);
    this.colorData.lightnessData.addEvent('change', (function(step) {
      return this.hslacone.setStyle('opacity', step / 100);
    }).bind(this));
    this.colorData.hueData.addEvent('change', (function(value) {
      return this.positionKnob(value, this.colorData.get('saturation'));
    }).bind(this));
    this.colorData.saturationData.addEvent('change', (function(value) {
      return this.positionKnob(this.colorData.get('hue'), value);
    }).bind(this));
    this.background.setStyles({
      'position': 'absolute',
      'z-index': 0
    });
    this.hslacone.setStyles({
      'position': 'absolute',
      'z-index': 1
    });
    this.xy = new Drag.Move(this.knob);
    this.xy.addEvent('beforeStart', (function(el, e) {
      return this.lastPosition = el.getPosition(this.wrapper);
    }).bind(this));
    this.xy.addEvent('drag', (function(el, e) {
      var an, position, sat, x, y;
      if (this.enabled) {
        position = el.getPosition(this.wrapper);
        x = this.center.x - position.x - this.knobSize.x / 2;
        y = this.center.y - position.y - this.knobSize.y / 2;
        this.radius = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
        this.angle = Math.atan2(y, x);
        if (this.radius > this.halfWidth) {
          el.setStyle('top', -Math.sin(this.angle) * this.halfWidth - this.knobSize.y / 2 + this.center.y);
          el.setStyle('left', -Math.cos(this.angle) * this.halfWidth - this.knobSize.x / 2 + this.center.x);
          this.saturation = 100;
        } else {
          sat = Math.round(this.radius);
          this.saturation = Math.round((sat / this.halfWidth) * 100);
        }
        an = Math.round(this.angle * (180 / Math.PI));
        this.hue = an < 0 ? 180 - Math.abs(an) : 180 + an;
        this.colorData.set('hue', this.hue);
        return this.colorData.set('saturation', this.saturation);
      } else {
        return el.setPosition(this.lastPosition);
      }
    }).bind(this));
    this.wrapper.adopt(this.background, this.hslacone, this.knob);
    return this.addChild(this.colorData);
  },
  drawHSLACone: function(width) {
    var ang, angle, c, c1, ctx, grad, i, w2, _ref, _results;
    ctx = this.background.getContext('2d');
    ctx.fillStyle = "#000";
    ctx.beginPath();
    ctx.arc(width / 2, width / 2, width / 2, 0, Math.PI * 2, true);
    ctx.closePath();
    ctx.fill();
    ctx = this.hslacone.getContext('2d');
    ctx.translate(width / 2, width / 2);
    w2 = -width / 2;
    ang = width / 50;
    angle = (1 / ang) * Math.PI / 180;
    i = 0;
    _results = [];
    for (i = 0, _ref = 360 * ang - 1; (0 <= _ref ? i <= _ref : i >= _ref); (0 <= _ref ? i += 1 : i -= 1)) {
      c = $HSB(360 + (i / ang), 100, 100);
      c1 = $HSB(360 + (i / ang), 0, 100);
      grad = ctx.createLinearGradient(0, 0, width / 2, 0);
      grad.addColorStop(0, c1.hex);
      grad.addColorStop(1, c.hex);
      ctx.strokeStyle = grad;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(width / 2, 0);
      ctx.stroke();
      _results.push(ctx.rotate(angle));
    }
    return _results;
  },
  update: function() {
    this.hslacone.set('width', this.size);
    this.hslacone.set('height', this.size);
    this.background.set('width', this.size);
    this.background.set('height', this.size);
    this.wrapper.setStyle('height', this.size);
    if (this.size > 0) {
      this.drawHSLACone(this.size);
    }
    this.colorData.set('size', this.size);
    this.knobSize = this.knob.getSize();
    this.halfWidth = this.size / 2;
    this.center = {
      x: this.halfWidth,
      y: this.halfWidth
    };
    return this.positionKnob(this.colorData.get('hue'), this.colorData.get('saturation'));
  },
  positionKnob: function(hue, saturation) {
    this.radius = saturation / 100 * this.halfWidth;
    this.angle = -((180 - hue) * (Math.PI / 180));
    this.knob.setStyle('top', -Math.sin(this.angle) * this.radius - this.knobSize.y / 2 + this.center.y);
    return this.knob.setStyle('left', -Math.cos(this.angle) * this.radius - this.knobSize.x / 2 + this.center.x);
  },
  ready: function() {
    return this.update();
  }
});
/*
---

name: Iterable.ListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.ListItem

requires:
  - G.UI/GDotUI
  - G.UI/Interfaces.Draggable
...
*/
Iterable.ListItem = new Class({
  Extends: Core.Abstract,
  Attributes: {
    label: {
      value: '',
      setter: function(value) {
        this.title.set('text', value);
        return value;
      }
    },
    "class": {
      value: 'blender-list-item'
    }
  },
  create: function() {
    this.title = new Element('div.title');
    this.base.grab(this.title);
    this.base.addEvent('click', __bind(function(e) {
      return this.fireEvent('select', [this, e]);
    }, this));
    return this.base.addEvent('click', __bind(function() {
      return this.fireEvent('invoked', this);
    }, this));
  }
});
/*
---

name: Data.DateTime

description:  Date & Time picker elements with Core.Slot-s

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - Core.Slot
  - G.UI/Data.Abstract
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Enabled
  - Iterable.ListItem

provides:
  - Data.DateTime
  - Data.Date
  - Data.Time

...
*/
Data.DateTime = new Class({
  Extends: Data.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Children, Interfaces.Size],
  Attributes: {
    "class": {
      value: Lattice.buildClass('date-time')
    },
    value: {
      value: new Date(),
      setter: function(value) {
        this.value = value;
        this.updateSlots();
        return value;
      }
    },
    time: {
      readonly: true,
      value: true
    },
    date: {
      readonly: true,
      value: true
    }
  },
  create: function() {
    this.yearFrom = GDotUI.Theme.Date.yearFrom;
    if (this.get('date')) {
      this.days = new Core.Slot();
      this.month = new Core.Slot();
      this.years = new Core.Slot();
    }
    if (this.get('time')) {
      this.hours = new Core.Slot();
      this.minutes = new Core.Slot();
    }
    this.populate();
    if (this.get('time')) {
      this.hours.addEvent('change', (function(item) {
        this.value.set('hours', item.value);
        return this.update();
      }).bind(this));
      this.minutes.addEvent('change', (function(item) {
        this.value.set('minutes', item.value);
        return this.update();
      }).bind(this));
    }
    if (this.get('date')) {
      this.years.addEvent('change', (function(item) {
        this.value.set('year', item.value);
        return this.update();
      }).bind(this));
      this.month.addEvent('change', (function(item) {
        this.value.set('month', item.value);
        return this.update();
      }).bind(this));
      this.days.addEvent('change', (function(item) {
        this.value.set('date', item.value);
        return this.update();
      }).bind(this));
    }
    return this;
  },
  populate: function() {
    var i, item, _results;
    if (this.get('time')) {
      i = 0;
      while (i < 24) {
        item = new Iterable.ListItem({
          label: (i < 10 ? '0' + i : i),
          removeable: false
        });
        item.value = i;
        this.hours.addItem(item);
        i++;
      }
      i = 0;
      while (i < 60) {
        item = new Iterable.ListItem({
          label: (i < 10 ? '0' + i : i),
          removeable: false
        });
        item.value = i;
        this.minutes.addItem(item);
        i++;
      }
    }
    if (this.get('date')) {
      i = 0;
      while (i < 30) {
        item = new Iterable.ListItem({
          label: i + 1,
          removeable: false
        });
        item.value = i + 1;
        this.days.addItem(item);
        i++;
      }
      i = 0;
      while (i < 12) {
        item = new Iterable.ListItem({
          label: i + 1,
          removeable: false
        });
        item.value = i;
        this.month.addItem(item);
        i++;
      }
      i = this.yearFrom;
      _results = [];
      while (i <= new Date().get('year')) {
        item = new Iterable.ListItem({
          label: i,
          removeable: false
        });
        item.value = i;
        this.years.addItem(item);
        _results.push(i++);
      }
      return _results;
    }
  },
  update: function() {
    var buttonwidth, last;
    this.fireEvent('change', this.value);
    buttonwidth = Math.floor(this.size / this.children.length);
    this.children.each(function(btn) {
      return btn.set('size', buttonwidth);
    });
    if (last = this.children.getLast()) {
      return last.set('size', this.size - buttonwidth * (this.children.length - 1));
    }
  },
  ready: function() {
    if (this.get('date')) {
      this.adoptChildren(this.years, this.month, this.days);
    }
    if (this.get('time')) {
      this.adoptChildren(this.hours, this.minutes);
    }
    console.log(this.size);
    return this.update();
  },
  updateSlots: function() {
    var cdays, i, item, listlength;
    if (this.get('date')) {
      cdays = this.value.get('lastdayofmonth');
      listlength = this.days.list.children.length;
      if (cdays > listlength) {
        i = listlength + 1;
        while (i <= cdays) {
          item = new Iterable.ListItem({
            label: i
          });
          item.value = i;
          this.days.addItem(item);
          i++;
        }
      } else if (cdays < listlength) {
        i = listlength;
        while (i > cdays) {
          this.days.list.removeItem(this.days.list.children[i - 1]);
          i--;
        }
      }
      this.days.list.set('selected', this.days.list.children[this.value.get('date') - 1]);
      this.month.list.set('selected', this.month.list.children[this.value.get('month')]);
      this.years.list.set('selected', this.years.list.getItemFromLabel(this.value.get('year')));
    }
    if (this.get('time')) {
      this.hours.list.set('selected', this.hours.list.children[this.value.get('hours')]);
      return this.minutes.list.set('selected', this.minutes.list.children[this.value.get('minutes')]);
    }
  }
});
Data.Time = new Class({
  Extends: Data.DateTime,
  Attributes: {
    "class": {
      value: Lattice.buildClass('time')
    },
    date: {
      value: false
    }
  }
});
Data.Date = new Class({
  Extends: Data.DateTime,
  Attributes: {
    "class": {
      value: Lattice.buildClass('date')
    },
    time: {
      value: false
    }
  }
});
/*
---

name: Data.Table

description: Text data element.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract

provides: Data.Table

...
*/
checkForKey = function(key, hash, i) {
  if (!(i != null)) {
    i = 0;
  }
  if (!(hash[key] != null)) {
    return key;
  } else {
    if (!(hash[key + i] != null)) {
      return key + i;
    } else {
      return checkForKey(key, hash, i + 1);
    }
  }
};
Data.Table = new Class({
  Extends: Data.Abstract,
  Binds: ['update'],
  options: {
    columns: 1,
    "class": GDotUI.Theme.Table["class"]
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    this.base.addClass(this.options["class"]);
    this.table = new Element('table', {
      cellspacing: 0,
      cellpadding: 0
    });
    this.base.grab(this.table);
    this.rows = [];
    this.columns = this.options.columns;
    this.header = new Data.TableRow({
      columns: this.columns
    });
    this.header.addEvent('next', (function() {
      this.addCloumn('');
      return this.header.cells.getLast().editStart();
    }).bind(this));
    this.header.addEvent('editEnd', (function() {
      this.fireEvent('change', this.getData());
      if (!this.header.cells.getLast().editing) {
        if (this.header.cells.getLast().getValue() === '') {
          return this.removeLast();
        }
      }
    }).bind(this));
    this.table.grab(this.header);
    this.addRow(this.columns);
    return this;
  },
  ready: function() {},
  addCloumn: function(name) {
    this.columns++;
    this.header.add(name);
    return this.rows.each(function(item) {
      return item.add('');
    });
  },
  removeLast: function() {
    this.header.removeLast();
    this.columns--;
    return this.rows.each(function(item) {
      return item.removeLast();
    });
  },
  addRow: function(columns) {
    var row;
    row = new Data.TableRow({
      columns: columns
    });
    row.addEvent('editEnd', this.update);
    row.addEvent('next', (function(row) {
      var index;
      index = this.rows.indexOf(row);
      if (index !== this.rows.length - 1) {
        return this.rows[index + 1].cells[0].editStart();
      }
    }).bind(this));
    this.rows.push(row);
    return this.table.grab(row);
  },
  removeRow: function(row, erase) {
    if (!(erase != null)) {
      erase = true;
    }
    row.removeEvents('editEnd');
    row.removeEvents('next');
    row.removeAll();
    if (erase) {
      this.rows.erase(row);
    }
    row.base.destroy();
    return delete row;
  },
  removeAll: function(addColumn) {
    if (!(addColumn != null)) {
      addColumn = true;
    }
    this.header.removeAll();
    this.rows.each((function(row) {
      return this.removeRow(row, false);
    }).bind(this));
    this.rows.empty();
    this.columns = 0;
    if (addColumn) {
      this.addCloumn();
      return this.addRow(this.columns);
    }
  },
  update: function() {
    var length, longest, rowsToRemove;
    length = this.rows.length;
    longest = 0;
    rowsToRemove = [];
    this.rows.each((function(row, i) {
      var empty;
      empty = row.empty();
      if (empty) {
        return rowsToRemove.push(row);
      }
    }).bind(this));
    rowsToRemove.each((function(item) {
      return this.removeRow(item);
    }).bind(this));
    if (this.rows.length === 0 || !this.rows.getLast().empty()) {
      this.addRow(this.columns);
    }
    return this.fireEvent('change', this.getData());
  },
  getData: function() {
    var headers, ret;
    ret = {};
    headers = [];
    this.header.cells.each(function(item) {
      var value;
      value = item.getValue();
      ret[checkForKey(value, ret)] = [];
      return headers.push(ret[value]);
    });
    this.rows.each((function(row) {
      if (!row.empty()) {
        return row.getValue().each(function(item, i) {
          return headers[i].push(item);
        });
      }
    }).bind(this));
    return ret;
  },
  getValue: function() {
    return this.getData();
  },
  setValue: function(obj) {
    var j, rowa, self;
    this.removeAll(false);
    rowa = [];
    j = 0;
    self = this;
    new Hash(obj).each(function(value, key) {
      self.addCloumn(key);
      value.each(function(item, i) {
        if (!(rowa[i] != null)) {
          rowa[i] = [];
        }
        return rowa[i][j] = item;
      });
      return j++;
    });
    rowa.each(function(item, i) {
      self.addRow(self.columns);
      return self.rows[i].setValue(item);
    });
    this.update();
    return this;
  }
});
Data.TableRow = new Class({
  Extends: Data.Abstract,
  Delegates: {
    base: ['getChildren']
  },
  options: {
    columns: 1,
    "class": ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    var i, _results;
    delete this.base;
    this.base = new Element('tr');
    this.base.addClass(this.options["class"]);
    this.cells = [];
    i = 0;
    _results = [];
    while (i < this.options.columns) {
      this.add('');
      _results.push(i++);
    }
    return _results;
  },
  add: function(value) {
    var cell;
    cell = new Data.TableCell({
      value: value
    });
    cell.addEvent('editEnd', (function() {
      return this.fireEvent('editEnd');
    }).bind(this));
    cell.addEvent('next', (function(cell) {
      var index;
      index = this.cells.indexOf(cell);
      if (index === this.cells.length - 1) {
        return this.fireEvent('next', this);
      } else {
        return this.cells[index + 1].editStart();
      }
    }).bind(this));
    this.cells.push(cell);
    return this.base.grab(cell);
  },
  empty: function() {
    var filtered;
    filtered = this.cells.filter(function(item) {
      if (item.getValue() !== '') {
        return true;
      } else {
        return false;
      }
    });
    if (filtered.length > 0) {
      return false;
    } else {
      return true;
    }
  },
  removeLast: function() {
    return this.remove(this.cells.getLast());
  },
  remove: function(cell, remove) {
    cell.removeEvents('editEnd');
    cell.removeEvents('next');
    this.cells.erase(cell);
    cell.base.destroy();
    return delete cell;
  },
  removeAll: function() {
    return (this.cells.filter(function() {
      return true;
    })).each((function(cell) {
      return this.remove(cell);
    }).bind(this));
  },
  getValue: function() {
    return this.cells.map(function(cell) {
      return cell.getValue();
    });
  },
  setValue: function(value) {
    return this.cells.each(function(item, i) {
      return item.setValue(value[i]);
    });
  }
});
Data.TableCell = new Class({
  Extends: Data.Abstract,
  Binds: ['editStart', 'editEnd'],
  options: {
    editable: true,
    value: ''
  },
  initialize: function(options) {
    return this.parent(options);
  },
  create: function() {
    delete this.base;
    this.base = new Element('td', {
      text: this.options.value
    });
    this.value = this.options.value;
    if (this.options.editable) {
      return this.base.addEvent('click', this.editStart);
    }
  },
  editStart: function() {
    var size;
    if (!this.editing) {
      this.editing = true;
      this.input = new Element('input', {
        type: 'text',
        value: this.value
      });
      this.base.set('html', '');
      this.base.grab(this.input);
      this.input.addEvent('change', (function() {
        return this.setValue(this.input.get('value'));
      }).bindWithEvent(this));
      this.input.addEvent('keydown', (function(e) {
        if (e.key === 'enter') {
          this.input.blur();
        }
        if (e.key === 'tab') {
          e.stop();
          return this.fireEvent('next', this);
        }
      }).bind(this));
      size = this.base.getSize();
      this.input.setStyles({
        width: size.x + "px !important",
        height: size.y + "px !important"
      });
      this.input.focus();
      return this.input.addEvent('blur', this.editEnd);
    }
  },
  editEnd: function(e) {
    if (this.editing) {
      this.editing = false;
    }
    this.setValue(this.input.get('value'));
    if (this.input != null) {
      this.input.removeEvents(['change', 'keydown']);
      this.input.destroy();
      delete this.input;
    }
    return this.fireEvent('editEnd');
  },
  setValue: function(value) {
    this.value = value;
    if (!this.editing) {
      return this.base.set('text', this.value);
    }
  },
  getValue: function() {
    if (!this.editing) {
      return this.base.get('text');
    } else {
      return this.input.get('value');
    }
  }
});
/*
---

name: Data.Unit

description: Color data element. ( color picker )

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract
  - Data.Number
  - Data.Select
  - G.UI/Interfaces.Children
  - G.UI/Interfaces.Size
  - G.UI/Interfaces.Enabled

provides: Data.Unit

...
*/
UnitList = {
  px: "px",
  '%': "%",
  em: "em",
  ex: "ex",
  gd: "gd",
  rem: "rem",
  vw: "vw",
  vh: "vh",
  vm: "vm",
  ch: "ch",
  "in": "in",
  mm: "mm",
  pt: "pt",
  pc: "pc",
  cm: "cm",
  deg: "deg",
  grad: "grad",
  rad: "rad",
  turn: "turn",
  s: "s",
  ms: "ms",
  Hz: "Hz",
  kHz: "kHz"
};
Data.Unit = new Class({
  Extends: Data.Abstract,
  Implements: [Interfaces.Enabled, Interfaces.Children, Interfaces.Size],
  Binds: ['update'],
  Attributes: {
    "class": {
      value: 'blender-unit'
    },
    value: {
      setter: function(value) {
        var match, unit;
        if (typeof value === 'string') {
          match = value.match(/(-?\d*)(.*)/);
          value = match[1];
          unit = match[2];
          this.sel.set('value', unit);
          return this.number.set('value', value);
        }
      },
      getter: function() {
        return String.from(this.number.value + this.sel.value);
      }
    }
  },
  update: function() {
    return this.fireEvent('change', String.from(this.number.value + this.sel.get('value')));
  },
  create: function() {
    this.addEvent('sizeChange', (function() {
      return this.number.set('size', this.size - this.sel.get('size'));
    }).bind(this));
    this.number = new Data.Number({
      range: [-50, 50],
      reset: true,
      steps: [100]
    });
    this.sel = new Data.Select({
      size: 80
    });
    Object.each(UnitList, (function(item) {
      return this.sel.addItem(new Iterable.ListItem({
        label: item,
        removeable: false,
        draggable: false
      }));
    }).bind(this));
    this.sel.set('value', 'px');
    this.number.addEvent('change', this.update);
    this.sel.addEvent('change', this.update);
    return this.adoptChildren(this.number, this.sel);
  },
  ready: function() {
    return this.set('size', this.size);
  }
});
/*
---

name: Data.List

description: Text data element.

requires:
  - G.UI/GDotUI
  - G.UI/Data.Abstract

provides: Data.List

...
*/
Data.List = new Class({
  Extends: Data.Abstract,
  Binds: ['update'],
  Attributes: {
    "class": {
      value: GDotUI.Theme.DataList["class"]
    }
  },
  create: function() {
    this.table = new Element('table', {
      cellspacing: 0,
      cellpadding: 0
    });
    this.base.grab(this.table);
    this.cells = [];
    return this.add('');
  },
  update: function() {
    this.cells.each((function(item) {
      if (item.getValue() === '') {
        return this.remove(item);
      }
    }).bind(this));
    if (this.cells.length === 0) {
      this.add('');
    }
    if (this.cells.getLast().getValue() !== '') {
      this.add('');
    }
    return this.fireEvent('change', {
      value: this.getValue()
    });
  },
  add: function(value) {
    var cell, tr;
    cell = new Data.TableCell({
      value: value
    });
    cell.addEvent('editEnd', this.update);
    cell.addEvent('next', function() {
      return cell.input.blur();
    });
    this.cells.push(cell);
    tr = new Element('tr');
    this.table.grab(tr);
    return tr.grab(cell);
  },
  remove: function(cell, remove) {
    cell.removeEvents('editEnd');
    cell.removeEvents('next');
    this.cells.erase(cell);
    cell.base.getParent('tr').destroy();
    cell.base.destroy();
    return delete cell;
  },
  removeAll: function() {
    return (this.cells.filter(function() {
      return true;
    })).each((function(cell) {
      return this.remove(cell);
    }).bind(this));
  },
  getValue: function() {
    var map;
    map = this.cells.map(function(cell) {
      return cell.getValue();
    });
    map.splice(this.cells.length - 1, 1);
    return map;
  },
  setValue: function(value) {
    var self;
    this.removeAll();
    self = this;
    return value.each(function(item) {
      return self.add(item);
    });
  }
});
/*
---

name: Dialog.Alert

description: Select Element

license: MIT-style license.

requires:
  - G.UI/Core.Abstract
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Alert

...
*/
Dialog.Alert = new Class({
  Extends: Dialog.Abstract,
  Attributes: {
    "class": {
      value: 'dialog-alert'
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
      value: 'dialog-alert-label',
      setter: function(value, old) {
        value = String.from(value);
        this.labelDiv.removeClass(old);
        this.labelDiv.addClass(value);
        return value;
      }
    }
  },
  update: function() {
    ({
      update: function() {}
    });
    this.labelDiv.setStyle('width', this.size);
    this.button.set('size', this.size);
    return this.base.setStyle('width', 'auto');
  },
  create: function() {
    this.parent();
    this.labelDiv = new Element('div');
    this.button = new Buttons.Abstract();
    this.base.adopt(this.labelDiv, this.button);
    return this.button.addEvent('invoked', __bind(function(el, e) {
      this.fireEvent('invoked', [this, e]);
      return this.hide(e, true);
    }, this));
  }
});
/*
---

name: Dialog.Confirm

description: Select Element

license: MIT-style license.

requires:
  - G.UI/Core.Abstract
  - Dialog.Abstract
  - Buttons.Abstract

provides: Dialog.Confirm

...
*/
Dialog.Confirm = new Class({
  Extends: Dialog.Abstract,
  Attributes: {
    "class": {
      value: 'dialog-confirm'
    },
    label: {
      value: '',
      setter: function(value) {
        return this.labelDiv.set('text', value);
      }
    },
    okLabel: {
      value: 'Ok',
      setter: function(value) {
        return this.okButton.set('label', value);
      }
    },
    cancelLabel: {
      value: 'Cancel',
      setter: function(value) {
        return this.cancelButton.set('label', value);
      }
    },
    labelClass: {
      value: 'dialog-alert-label',
      setter: function(value, old) {
        value = String.from(value);
        this.labelDiv.removeClass(old);
        this.labelDiv.addClass(value);
        return value;
      }
    }
  },
  update: function() {
    var cancelsize, oksize;
    this.labelDiv.setStyle('width', this.size);
    this.okButton.set('size', this.size / 2);
    this.cancelButton.set('size', this.size / 2);
    oksize = this.okButton.getSize().x;
    cancelsize = this.cancelButton.getSize().x;
    return this.base.setStyle('width', oksize + cancelsize);
  },
  create: function() {
    this.parent();
    this.labelDiv = new Element('div');
    this.okButton = new Buttons.Abstract();
    this.cancelButton = new Buttons.Abstract();
    $$(this.okButton.base, this.cancelButton.base).setStyle('float', 'left');
    this.base.adopt(this.labelDiv, this.okButton, this.cancelButton, new Element('div', {
      style: "clear: both"
    }));
    this.okButton.addEvent('invoked', __bind(function(el, e) {
      this.fireEvent('invoked', [this, e]);
      return this.hide(e, true);
    }, this));
    return this.cancelButton.addEvent('invoked', __bind(function(el, e) {
      this.fireEvent('cancelled', [this, e]);
      return this.hide(e, true);
    }, this));
  }
});
/*
---

name: Iterable.MenuListItem

description: List items for Iterable.List.

license: MIT-style license.

requires: Core.Abstract

provides: Iterable.MenuListItem

requires:
  - G.UI/GDotUI
  - G.UI/Interfaces.Draggable
...
*/
Iterable.MenuListItem = new Class({
  Extends: Iterable.ListItem,
  Attributes: {
    icon: {
      setter: function(value) {
        return this.iconEl.set('image', value);
      }
    },
    shortcut: {
      setter: function(value) {
        this.sc.set('text', value.toUpperCase());
        return value;
      }
    },
    "class": {
      value: 'blender-menu-list-item'
    }
  },
  create: function() {
    this.parent();
    this.iconEl = new Core.Icon({
      "class": 'blender-menu-list-item-icon'
    });
    this.sc = new Element('div.shortcut');
    this.sc.setStyle('float', 'right');
    this.title.setStyle('float', 'left');
    this.iconEl.base.setStyle('float', 'left');
    this.base.grab(this.iconEl, 'top');
    return this.base.grab(this.sc);
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
  - Core.Button
  - Iterable.ListItem

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
      value: null,
      setter: function(newv, oldv) {
        if (oldv != null) {
          oldv.base.removeClass('bv-selected');
          oldv.base.setStyle('border', '');
        }
        newv.base.addClass('bv-selected');
        newv.base.setStyle('border', '1px solid #888');
        return newv;
      }
    }
  },
  toggleFullScreen: function(view) {
    this.emptyNeigbours();
    if (!view.fullscreen) {
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
      view.base.setStyle('z-index', 100);
    } else {
      view.fullscreen = false;
      view.base.setStyle('z-index', 1);
      view.set('top', view.lastPosition.top);
      view.set('bottom', view.lastPosition.bottom);
      view.set('left', view.lastPosition.left);
      view.set('right', view.lastPosition.right);
    }
    return this.calculateNeigbours();
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
  deleteView: function(view) {
    var n;
    this.emptyNeigbours();
    n = this.getFullNeigbour(view);
    if (n != null) {
      n.view.set(n.side, view.get(n.side));
      this.removeChild(this.active);
      this.set('active', n.view);
    }
    return this.calculateNeigbours();
  },
  getFullNeigbour: function(view) {
    var ret;
    ret = {
      side: null,
      view: null
    };
    if (ret.view = this.getNeigbour(view, 'left')) {
      ret.side = 'right';
      return ret;
    }
    if (ret.view = this.getNeigbour(view, 'right')) {
      ret.side = 'left';
      return ret;
    }
    if (ret.view = this.getNeigbour(view, 'top')) {
      ret.side = 'bottom';
      return ret;
    }
    if (ret.view = this.getNeigbour(view, 'bottom')) {
      ret.side = 'top';
      return ret;
    }
  },
  getNeigbour: function(view, prop) {
    var mod, opp, ret, third, val, val1;
    mod = prop;
    switch (mod) {
      case 'right':
        opp = 'left';
        third = 'height';
        break;
      case 'left':
        third = 'height';
        opp = 'right';
        break;
      case 'top':
        third = 'width';
        opp = 'bottom';
        break;
      case 'bottom':
        third = 'width';
        opp = 'top';
    }
    ret = null;
    val = view.get(mod);
    val1 = view.get(third);
    this.children.each(function(it) {
      var v, w;
      if (it !== view) {
        w = it.get(third);
        v = it.get(opp);
        if (v.inRange(val, 3) && w.inRange(val1, 3)) {
          return ret = it;
        }
      }
    });
    return ret;
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
        if (v.inRange(val, 5)) {
          ret.opp.push(it);
        }
        v = it.get(mod);
        if (v.inRange(val, 5)) {
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
  fromObj: function(obj) {
    var view, _i, _len;
    this.emptyNeigbours();
    for (_i = 0, _len = obj.length; _i < _len; _i++) {
      view = obj[_i];
      this.addView(new Blender.View(view));
    }
    return this.calculateNeigbours();
  },
  create: function() {
    this.i = 0;
    this.stack = {};
    this.hooks = [];
    this.views = [];
    window.addEvent('keydown', (function(e) {
      if (e.key === 'up' && e.control) {
        this.toggleFullScreen(this.get('active'));
      }
      if (e.key === 'delete' && e.control) {
        return this.deleteView(this.active);
      }
    }).bind(this));
    window.addEvent('resize', this.update.bind(this));
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
    this.updateToolBar(view);
    view.base.addEvent('click', (function() {
      return this.set('active', view);
    }).bind(this));
    view.addEvent('split', this.splitView.bind(this));
    view.addEvent('content-change', (function(e) {
      if (e != null) {
        return this.setViewContent(e, view);
      }
    }).bind(this));
    if (view.stack != null) {
      return view.toolbar.select.list.items.each(function(item) {
        if (item.label === view.stack) {
          return this.set('selected', item);
        }
      }, view.toolbar.select.list);
    }
  },
  setViewContent: function(viewContent, view) {
    var content;
    if (!this.stack[viewContent].unique) {
      content = new this.stack[viewContent]["class"]();
    } else {
      if (this.stack[viewContent].content != null) {
        content = this.stack[viewContent].content;
        this.stack[viewContent].owner.set('content', null);
        this.stack[viewContent].owner.toolbar.select.list.set('selected', null);
      } else {
        content = this.stack[viewContent].content = new this.stack[viewContent]["class"]();
      }
      this.stack[viewContent].owner = view;
    }
    return view.set('content', content);
  },
  addToStack: function(name, viewContent, unique) {
    this.stack[name] = {
      "class": viewContent,
      unique: unique
    };
    return this.updateToolBars();
  },
  updateToolBar: function(view) {
    view.toolbar.select.list.removeAll();
    return Object.each(this.stack, function(value, key) {
      return this.addItem(new Iterable.BlenderListItem({
        label: key,
        removeable: false,
        draggable: false
      }));
    }, view.toolbar.select);
  },
  updateToolBars: function() {
    return this.children.each(function(child) {
      return this.updateToolBar(child);
    }, this);
  }
});
/*
---

name: Blender.Corner

description: Viewport

license: MIT-style license.

requires:
  - Core.Icon

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

name: Blender.Toolbar

description: Viewport

license: MIT-style license.

requires:
  - G.UI/Core.Abstract
  - G.UI/Interfaces.Children
  - Data.Select

provides: Blender.Toolbar

...
*/
Interfaces.HorizontalChildren = new Class({
  Extends: Interfaces.Children,
  addChild: function(el, where) {
    this.children.push(el);
    document.id(el).setStyle('float', 'left');
    return this.base.grab(el, where);
  }
});
Blender.Toolbar = new Class({
  Extends: Core.Abstract,
  Implements: Interfaces.HorizontalChildren,
  Attributes: {
    "class": {
      value: 'blender-toolbar'
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
        value = Number.eval(value, window.getSize().y);
        this.base.setStyle('top', value + 1);
        return value;
      }
    },
    width: {
      getter: function() {
        return this.get('right') - this.get('left');
      }
    },
    height: {
      getter: function() {
        return this.get('bottom') - this.get('top');
      }
    },
    left: {
      setter: function(value) {
        value = Number.eval(value, window.getSize().x);
        this.base.setStyle('left', value);
        return value;
      }
    },
    right: {
      setter: function(value) {
        value = Number.eval(value, window.getSize().x);
        this.base.setStyle('right', window.getSize().x - value + 1);
        return value;
      }
    },
    bottom: {
      setter: function(value) {
        value = Number.eval(value, window.getSize().y);
        this.base.setStyle('bottom', window.getSize().y - value);
        return value;
      }
    },
    content: {
      value: null,
      setter: function(newVal, oldVal) {
        if (oldVal) {
          this.removeChild(oldVal);
          if (oldVal.toolbar != null) {
            this.toolbar.removeChild(oldVal.toolbar);
          }
        }
        delete oldVal;
        if (newVal != null) {
          if (newVal.base != null) {
            newVal.base.setStyle('position', 'relative');
          }
          this.addChild(newVal, 'top');
          if (newVal.toolbar != null) {
            this.toolbar.addChild(newVal.toolbar);
          }
        }
        return newVal;
      }
    },
    stack: {
      setter: function(value) {
        this.fireEvent('content-change', value);
        return value;
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
    width = this.base.getSize().x - 30;
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
  updateScrollTop: function() {
    return this.content.base.setStyle('top', ((this.base.getSize().y - this.content.base.getSize().y - 30) / 100) * this.slider.get('value'));
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
    this.slider = new Core.Srcollbar({
      steps: 100,
      mode: 'vertical'
    });
    this.slider.minSize = 0;
    this.slider.base.setStyle('min-height', 0);
    this.slider.addEvent('step', this.updateScrollTop.bind(this));
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
        if ((dir === 'bottom' || dir === 'top') && this.get('top') !== 0) {
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
        if ((dir === 'left' || dir === 'right') && this.get('right') !== window.getSize().x) {
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
      if ((dir === 'bottom' || dir === 'top') && this.get('bottom') !== window.getSize().y) {
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
      if ((dir === 'left' || dir === 'right') && this.get('left') !== 0) {
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
/*
---

name: Pickers

description: Pickers for Data classes.

license: MIT-style license.

requires:
  - G.UI/GDotUI
  - Core.Picker
  - Data.Color
  - Data.Number
  - Data.Text
  - Data.Date
  - Data.Time
  - Data.DateTime

provides: [Pickers.Base, Pickers.Color, Pickers.Number, Pickers.Text, Pickers.Time, Pickers.Date, Pickers.DateTime ]

...
*/
Pickers.Base = new Class({
  Extends: Core.Picker,
  Delegates: {
    data: ['set']
  },
  Attributes: {
    type: {
      value: null
    }
  },
  show: function(e, auto) {
    if (this.data === void 0) {
      this.data = new Data[this.type]();
      this.set('content', this.data);
    }
    return this.parent(e, auto);
  }
});
Pickers.Color = new Pickers.Base({
  type: 'ColorWheel'
});
Pickers.Number = new Pickers.Base({
  type: 'Number'
});
Pickers.Time = new Pickers.Base({
  type: 'Time'
});
Pickers.Text = new Pickers.Base({
  type: 'Text'
});
Pickers.Date = new Pickers.Base({
  type: 'Date'
});
Pickers.DateTime = new Pickers.Base({
  type: 'DateTime'
});
Pickers.Table = new Pickers.Base({
  type: 'Table'
});
Pickers.Unit = new Pickers.Base({
  type: 'Unit'
});
Pickers.Select = new Pickers.Base({
  type: 'Select'
});
Pickers.List = new Pickers.Base({
  type: 'List'
});
