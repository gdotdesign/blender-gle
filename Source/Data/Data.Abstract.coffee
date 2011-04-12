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
