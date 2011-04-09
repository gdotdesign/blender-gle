Field = new Class({
    Extends: Drag.Move,
    Implements: [Class.Occlude, Class.Binds],
    Binds: ['containerClicked'],
    options: {
      
        setOnClick: true,
        initialStep: false,
        x: [0, 1, false],
        y: [0, 1, false]

    },
    initialize: function(field, knob, options){
        var field = $(field);
        
        if(this.occlude('xy-field', field)) return this.occluded;
        
        this.container = field; //We do this because we need it when attach is called.
        
        $defined(options) ? (options.container = field) : options = {container: field};
        this.setOptions(options);
        this.parent($(knob), options);
        
        this.calculateLimit();
        
        if(!this.options.initialStep) this.options.initialStep = {x: this.options.x[0], y: this.options.y[0]};
        this.set(this.options.initialStep)
    },
    calculateLimit: function(){
      this.limit = this.parent();
      this.calculateStepFactor();
      return this.limit;
    },
    calculateStepFactor: function(){
        this.offset = {
            x: this.limit.x[0] + this.element.getStyle('margin-left').toInt() - this.container.offsetLeft,
            y: this.limit.y[0] + this.element.getStyle('margin-top').toInt() - this.container.offsetTop
        };
        
        var movableWidth = this.limit.x[1] - this.limit.x[0];
        var movableHeight = this.limit.y[1] - this.limit.y[0];
        
        if(this.options.x[2] === false) this.options.x[2] = movableWidth;
        if(this.options.y[2] === false) this.options.y[2] = movableHeight;
        
        var steps = {x: (this.options.x[2] - this.options.x[0])/this.options.x[1],
                     y: (this.options.y[2] - this.options.y[0])/this.options.y[1]};
   
        
        this.stepFactor = {
            x: movableWidth/steps.x,
            y: movableHeight/steps.y
        };
    },
    containerClicked: function(e){
        if(e.target == this.element) return;
        e.stop();
        var containerPosition = this.container.getPosition();
        var position = {
            x: e.page.x - containerPosition.x + this.element.getStyle('margin-left').toInt(),
            y: e.page.y - containerPosition.y + this.element.getStyle('margin-top').toInt()
        }
        this.set(this.toSteps(position));
        return e;
    },
    toSteps: function(position){
        var steps = {x: (position.x - this.offset.x)/this.stepFactor.x * this.options.x[1],
                     y: (position.y - this.offset.y)/this.stepFactor.y * this.options.y[1]};
        
        steps.x = Math.round(steps.x - steps.x % this.options.x[1]) + this.options.x[0];
        steps.y = Math.round(steps.y - steps.y % this.options.y[1]) + this.options.y[0];
        return steps;
    },
    toPosition: function(steps){
    	var position = {};
        var xmin = (this.options.x[2] - this.options.x[0]) < 0 ? Math.min : Math.max;
        var xmax = (this.options.x[2] - this.options.x[0]) < 0 ? Math.max : Math.min;
        
        var ymin = (this.options.y[2] - this.options.y[0]) < 0 ? Math.max : Math.min;
        var ymax = (this.options.y[2] - this.options.y[0]) < 0 ? Math.min : Math.max;
        
        position.x = (this.stepFactor.x * (xmax(xmin(steps.x, this.options.x[0]), this.options.x[2]) - this.options.x[0]) + this.offset.x) / this.options.x[1] + this.container.offsetLeft;
        position.y = (this.stepFactor.y * (ymin(ymax(steps.y, this.options.y[0]), this.options.y[2]) - this.options.y[0]) + this.offset.y) / this.options.y[1] + this.container.offsetTop;
        return position
    },
    toElement: function(){
      return this.container;  
    },
    stop: function(event){
        var position = this.get();
        this.fireEvent('complete', position);
        this.fireEvent('change', position);
        return this.parent(false);
    },
    drag: function(event){
        var position = this.get();
        this.fireEvent('tick', position);
        this.fireEvent('change', position);
        return this.parent(event);
    },
    set: function(steps){
        var position = this.toPosition(steps)
        this.element.setPosition(position);
        this.fireEvent('change', this.get());
    },
    get: function(){
        return this.toSteps(this.element.getPosition(this.container));
    },
    attach: function(){
        if(this.options.setOnClick) this.container.addEvent('click', this.containerClicked);
        this.parent();
    },
    detach: function(){
        if(this.options.setOnClick) this.container.removeEvent('click', this.containerClicked);
        this.parent();
    }
});
Class.Mutators.Delegates = function(delegations) {
	var self = this;
	new Hash(delegations).each(function(delegates, target) {
		$splat(delegates).each(function(delegate) {
			self.prototype[delegate] = function() {
				var ret = this[target][delegate].apply(this[target], arguments);
				return (ret === this[target] ? this : ret);
			};
		});
	});
};
