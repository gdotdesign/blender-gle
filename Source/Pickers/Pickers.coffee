###
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
