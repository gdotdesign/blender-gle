/*
---

name: Packager

description: Javascript for packager-web's frontend.

license: MIT-style license.

requires: [Core/Array, Core/Element.Style, Core/Element.Event, Core/DomReady, Core/Request]

provides: Packager

...
*/

(function(){

var packages = {},
    components = {};

var Packager = this.Packager = {

    init: function(form){
        Packager.form = this.form = document.id(form || 'packager');

        this.form.getElements('.package').each(function(element){
            var name = element.get('id').substr(8);

            var pkg = packages[name] = {
                enabled: true,
                element: element,
                toggle: element.getElement('.toggle'),
                components: []
            };

            element.getElements('input[type=checkbox], input[type=radio]').each(function(element){
                var radio = element.get('type') == 'radio',
                    exclude = element.hasClass('exclude');
                
                if (radio && element.get('checked')) element.set('checked', true);
                else if (!radio && element.get('checked') && exclude) element.set('checked', true);
                else element.set('checked', false);
                element.setStyle('display', 'none');

                var depends = element.get('data-depends'),
                    name = element.get('value'),
                    parent = element.getParent('tr');

                depends = depends ? depends.split(', ') : [];

                pkg.components.push(name);
                var component = components[name] = {
                    element: element,
                    depends: depends,
                    parent: parent,
                    checker: parent.getElement('div'),
                    selected: false,
                    required: []
                };
                
                //parent.set('morph', {duration: 200});
                //component.checker.set('morph', {duration: 140});
                
                parent.addListener('click', function(){
                    if (element.get('type') == 'radio'){
                        if (!element.checked){
                            Packager.select(name);
                            Packager.uncheckByName(element.get('name'), name);
                        }
                    } else {
                        if (component.selected) Packager.deselect(name);
                        else Packager.select(name);
                    }

                    Packager.setLocationHash();
                });
                
                if ((radio && element.checked) || (exclude && element.checked)) Packager.select(name);
            });

            var select = element.getElement('.select');
            if (select) select.addListener('click', function(e){
                e.preventDefault();
                Packager.selectPackage(name);
            });

            var deselect = element.getElement('.deselect');
            if (deselect) deselect.addListener('click', function(e){
                e.preventDefault();
                Packager.deselectPackage(name);
            });

            var disable = element.getElement('.disable');
            if (disable) disable.addListener('click', function(){
                Packager.disablePackage(name);
            });

            var enable = element.getElement('.enable');
            if (enable) enable.addListener('click', function(){
                Packager.enablePackage(name);
            });

        });

        this.form.addEvents({
            submit: function(event){
                if (!Packager.getSelected().length) event.stop();
            },
            reset: function(event){
                event.stop();
                Packager.reset();
            }
        });
                
        
        //Packager.hashload = this.form.getElement('.hash-loader input[type=text]');
        
        //Packager.Remote.init();
    },

    check: function(name){
        var component = components[name],
            element = component.element;

        if (!component.selected && !component.required.length) return;

        if (component.selected) element.set('checked', true);
        //component.parent.addClass('checked').removeClass('unchecked');
        //component.parent.morph('.focused');

        component.depends.each(function(dependancy){
            Packager.require(dependancy, name);
        });
    },

    uncheck: function(name){
        var component = components[name],
            element = component.element;

        if (component.selected || component.required.length) return;

        element.set('checked', false);
        //component.parent.addClass('unchecked').removeClass('checked');
        //component.parent.morph('.blurred');

        component.depends.each(function(dependancy){
            Packager.unrequire(dependancy, name);
        });
    },

    uncheckByName: function(name, input){
        $$('input[name=' + name + ']').each(function(other){
            other = other.get('id');
            if (other != input) Packager.deselect(other);
        });
    },
    
    select: function(name){
        var component = components[name];

        if (!component){
            var matches = name.match(/(.+)\/\*$/);
            if (matches) this.selectPackage(matches[1]);
            return;
        }

        if (component.selected) return;

        component.selected = true;
        component.parent.addClass('selected');
        //component.checker.morph('.checked');

        this.check(name);
    },

    deselect: function(name, reset){
        var component = components[name],
            exclude = component.element.hasClass('exclude');

        if (!component || !component.selected || (reset && exclude)) return;

        component.selected = false;
        component.parent.removeClass('selected');
        //component.checker.morph(component.parent.hasClass('required') ? '.required' : '.input');

        this.uncheck(name);
    },

    require: function(name, req){
      console.log(name);
        var component = components[name];
        if (!component) return;

        var required = component.required;
        if (required.contains(req)) return;

        required.push(req);
        component.parent.addClass('required');
        //if (!component.parent.hasClass('selected')) component.checker.morph('.required');

        this.check(name);
    },

    unrequire: function(name, req){
        var component = components[name];
        if (!component) return;

        var required = component.required;
        if (!required.contains(req)) return;

        required.erase(req);
        if (!required.length){
            component.parent.removeClass('required');
            //component.checker.morph(component.parent.hasClass('selected') ? '.checked' : '.input');
        }

        this.uncheck(name);
    },

    selectPackage: function(name){
        var pkg = packages[name];
        if (!pkg) return;

        pkg.components.each(function(name){
            if (!components[name].element.hasClass('exclude')) Packager.select(name);
        });

        this.setLocationHash();
    },

    deselectPackage: function(name){
        var pkg = packages[name];
        if (!pkg) return;

        pkg.components.each(function(name){
            if (!components[name].element.hasClass('exclude')) Packager.deselect(name);
        });

        this.setLocationHash();
    },

    enablePackage: function(name){
        var pkg = packages[name];
        if (!pkg || pkg.enabled) return;

        pkg.enabled = true;
        pkg.element.removeClass('package-disabled');
        pkg.element.getElement('tr').removeClass('last');
        pkg.toggle.set('value', '');

        pkg.components.each(function(name){
            components[name].element.set('disabled', false);
        });

        this.setLocationHash();
    },

    disablePackage: function(name){
        var pkg = packages[name];
        if (!pkg || !pkg.enabled) return;

        this.deselectPackage(name);

        pkg.enabled = false;
        pkg.element.addClass('package-disabled');
        pkg.element.getElement('tr').addClass('last');
        pkg.toggle.set('value', name);

        pkg.components.each(function(name){
            components[name].element.set('disabled', true);
        });

        this.setLocationHash();
    },

    getSelected: function(){
        var selected = [], exclude;
        for (var name in components) {
            exclude = components[name].element.className.contains('exclude');
            if (components[name].selected && !exclude) selected.push(name);
        }
        return selected;
    },

    getDisabledPackages: function(){
        var disabled = [];
        for (var name in packages) if (!packages[name].enabled) disabled.push(name);
        return disabled;
    },
    
    getUrl: function(){
        loc = window.location;
        return loc.protocol + '//' + loc.hostname + loc.pathname;
    },

    toQueryString: function(){
        var selected = this.getSelected(),
            disabled = this.getDisabledPackages(),
            query = [];

        if (selected.length) query.push('select=' + selected.join(';'));
        if (disabled.length) query.push('disable=' + disabled.join(';'));

        return query.join('&') || '!';
    },

    setLocationHash: function(){
        //var selected = this.getSelected(),
        //    value = (selected.length) ? MD5(selected.join(';')) : '';
        
        //this.hashload.set('value', value);
        //this.hashload.fireEvent('change', [selected]);
    },

    fromHash: function(hash){
        this.reset();
        if (!hash || hash == 'hash not found') return;
        
        var parts = hash.split(';');
        parts.each(function(name){
            Packager.select(name);
        });

        this.hashload.fireEvent('load', [this.getSelected()]);
        this.setLocationHash();
    },

    reset: function(){
        for (var name in components) this.deselect(name, true);
        for (var name in packages) this.enablePackage(name);
        //this.setLocationHash();
    }

};


document.addEvent('domready', Packager.init);

})();

