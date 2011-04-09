GDotUI={}
GDotUI.Theme={
    Global:{
        active: 'active',
        inactive: 'inactive'
    },
    IconGroup: {
      class: 'icongroup'
    },
    Icons:{
      add:'../Themes/Chrome/images/add.png',  
      remove:'../Themes/Chrome/images/delete.png',
      edit: '../Themes/Chrome/images/pencil.png',
      handleVertical:'../Themes/Chrome/images/control_pause.png',
      handleHorizontal:''
    },
    Button:{
        'class':'button',
        label: 'Button',
    },
    Push:{
        'class':'push',
        label: 'Push!',
    },
    PushGroup:{
        'class':'pushgroup',
    },
    Toggler:{
      'class': 'toggler',
      onClass: 'on',
      offClass: 'off',
      separatorClass: 'sep',
      onText: 'ON',
      offText: 'OFF'
    },
    Float:{
        'class':'float',
        bottomHandle:'bottom',
        topHandle:'handle',
        content:'base',
        controls:'controls',
        iconOptions:{
            mode:'vertical',
            spacing:{
                x:0,
                y:5
            }
        }
    },
    Unit:{
        'class':'unit-pick'
    },
    Select: {
        'class':'select',
        textClass: 'text',
        addClass: 'add',
        removeClass: 'remove',
        listClass: 'select-list',
        listItemClass: 'select-item',
    },
    Table:{
        'class':'table'
    },
    Text:{
        'class':'text'
    },
    Icon:{
        'class':'icon'
    },
    Overlay:{
        'class':'overlay'
    },
    Picker:{
        'class':'picker',
        event: 'click',
        picking: 'picking',
        offset: 10
    },
    DataList:{
        'class':'data-list'
    },
    Slider:{
      classes: {
        base: 'slider',
        bar: 'progress',
      }
    },
    Slot:{
        'class':'slot'  
    },
    Tab:{
        'class':'tab'
    },
    Tabs:{
        'class':'tabs'
    },
    Tip:{
        'class':'tip',
        offset: 5,
        location: { x:"right",
                    y:"center" }
    },
    Date:{
      'class':'date',
      yearFrom: 1980,
      format:'%Y %B %d - %A',
      DateTime:{
        'class':'date-time',
        format:'%Y %B %d - %A %H:%M'
      },
      Time:{
        'class':'time',
        format:'%H:%M'
      }
    },
    Number:{
        range:[-100,100],
        steps:200,
        reset: true,
        mode: 'vertical',
        classes: {
          base: 'number',
          bar: 'progress',
          text: 'text'
        }
    },
    List:{
      'class':'list',
      selected: 'selected'
    },
    ListItem:{
      'class':'list-item',
      title:'title',
      subTitle:'subtitle',
      handle:'list-handle',
      offset:2
    },
    Forms:{
        Field:{
            struct:{
                "dl":{
                    "dt":{
                        "label":''
                    },
                    "dd":{
                        "input":''
                    }
                }
            }
        }
    },
    Color:{
       sb:'sb',
       black:'black',
       white:'white',
       wrapper:'wrapper',
      'class':'color',
       format: 'hex', 
       controls:{
          'class':'slotcontrol'
       }
    }
}
