asd = new Class({
Extends: Core.Abstract,
create: function(){
  this.base.setStyles({
    'background-image':'url(../gdotui/Themes/Chrome/images/grid5.png)',
    'width':'100%',
    'height':'100%'
  })
  
}
});
asd1 = new Class({
Extends: Core.Abstract,
Implements: [Interfaces.Children,Interfaces.Size],
  update: function(){
    this.button.set('size',this.size);
    this.pushButton.set('size',this.size);
    this.number.set('size',this.size);
    this.toggler.set('size',this.size);
    this.group.set('size',this.size);
    this.select.set('size',this.size);
    this.unit.set('size',this.size);
    this.texta.set('size',this.size);
  },
create: function(){
  this.pushButton = new Core.Push({label:'Push Button!'});
  this.button = new Core.Button({label:"Default Button!"});
  this.toggler = new Core.Toggler();
  this.texta = new Data.Text();
  this.number = new Data.Number();
  
  this.group = new Core.PushGroup();
  this.group.addItem(new Core.Push({label:1}));  
  this.group.addItem(new Core.Push({label:2})); 
  this.group.addItem(new Core.Push({label:3})); 
  this.group.addItem(new Core.Push({label:4})); 
  this.group.addItem(new Core.Push({label:5})); 
  
  this.unit = new Data.Unit();
  
  this.select = new Data.Select({'default':'background-break'});
  list = [' bounding-box','each-box','continuous','border-box','padding-box','content-box','no-clip']
  list.each(function(item){
    this.select.addItem(new Iterable.ListItem({label:item,removeable:false,draggable:false}))
  },this);
  this.adoptChildren( this.button,this.pushButton, this.toggler, this.number, this.select, this.unit,this.group,this.texta);
}
});
window.addEvent('domready', function(){
slider = new Blender();
document.body.grab(slider);
slider.addToStack('node editor',asd,true)
slider.addToStack('preview',asd1,true)
slider.addToStack('info',Core.Abstract)
slider.fromObj([
{top: "0", left: "0",right: "100%-300",bottom:"32",stack:'info'},
{top: "32", left: "0",right: "100%-300",bottom:"100%-150",stack:'node editor'},
{top: "100%-150", left: "0",right: "100%-300",bottom:"100%"},
{top: "0", left: "100%-300" ,right: "100%",bottom:"200",stack:'preview'},
{top: 200, left: "100%-300" ,right: "100%",bottom:"100%",stack:'preview'}
]);
});
