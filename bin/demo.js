// Generated by Haxe
(function (console) { "use strict";
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,replace: function(s,by) {
		return s.replace(this.r,by);
	}
};
var HxOverrides = function() { };
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Main = function() {
	var options = { suggestions : ["Apple","Banana","Carrot","Peach","Pear","Turnip"]};
	var input = window.document.querySelector("input.fancify");
	this.search = new fancy_Search(input,options);
};
Main.main = function() {
	new Main();
};
var Reflect = function() { };
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
var fancy_Search = function(el,options) {
	this.input = el;
	if(options != null) options = options; else options = { };
	if(options.container != null) this.container = options.container; else this.container = this.input.parentElement;
	if(options.classes != null) options.classes = options.classes; else options.classes = { };
	if(options.keys != null) options.keys = options.keys; else options.keys = { };
	this.classes = thx_Objects.combine({ input : "fs-search-input", suggestionContainer : "fs-suggestion-container", suggestionsOpen : "fs-suggestion-container-open", suggestionsClosed : "fs-suggestion-container-closed", suggestionList : "fs-suggestion-list", suggestionItem : "fs-suggestion-item", suggestionItemMatch : "fs-suggestion-item-positive", suggestionItemFail : "fs-suggestion-item-negative", suggestionItemSelected : "fs-suggestion-item-selected"},options.classes);
	this.keys = thx_Objects.combine({ closeMenu : [fancy_util_Keys.ESCAPE], selectionUp : [fancy_util_Keys.UP], selectionDown : [fancy_util_Keys.DOWN]},options.keys);
	this.list = new fancy_Suggestions({ parent : this.container, suggestions : options.suggestions, filterFn : options.filter, classes : { suggestionContainer : this.classes.suggestionContainer, suggestionsOpen : this.classes.suggestionsOpen, suggestionsClosed : this.classes.suggestionsClosed, suggestionList : this.classes.suggestionList, suggestionItem : this.classes.suggestionItem, suggestionItemMatch : this.classes.suggestionItemMatch, suggestionItemFail : this.classes.suggestionItemFail, suggestionItemSelected : this.classes.suggestionItemSelected}});
	fancy_util_Dom.addClass(this.input,this.classes.input);
	fancy_util_Dom.on(this.input,"focus",$bind(this,this.onSearchFocus));
	fancy_util_Dom.on(this.input,"blur",$bind(this,this.onSearchBlur));
	fancy_util_Dom.on(this.input,"input",$bind(this,this.onSearchInput));
	fancy_util_Dom.on(this.input,"keyup",$bind(this,this.onSearchKeyup));
};
fancy_Search.prototype = {
	onSearchFocus: function(e) {
		if(this.list.filtered.length < this.list.suggestions.length && this.list.filtered.length > 0) this.list.open();
	}
	,onSearchBlur: function(e) {
		this.list.close();
	}
	,onSearchInput: function(e) {
		this.list.filter(this.input.value);
		this.list.open();
	}
	,onSearchKeyup: function(e) {
		var code;
		if(e.which != null) code = e.which; else code = e.keyCode;
		if(thx_Arrays.contains(this.keys.closeMenu,code)) this.list.close(); else if(thx_Arrays.contains(this.keys.selectionUp,code) && this.list.isOpen) this.list.moveSelectionUp(); else if(thx_Arrays.contains(this.keys.selectionDown,code) && this.list.isOpen) this.list.moveSelectionDown();
	}
};
var fancy_Suggestions = function(options) {
	var _g = this;
	this.parent = options.parent;
	this.classes = options.classes;
	if(options.suggestions != null) this.suggestions = options.suggestions; else this.suggestions = [];
	this.filtered = this.suggestions.slice();
	this.selected = "";
	if(options.filterFn != null) this.filterFn = options.filterFn; else this.filterFn = fancy_Suggestions.defaultFilterer;
	this.isOpen = false;
	this.elements = thx_Arrays.reduce(this.suggestions,function(acc,curr) {
		acc.set(curr,fancy_util_Dom.create("li." + _g.classes.suggestionItem + "." + _g.classes.suggestionItemMatch,null,null,curr));
		return acc;
	},new haxe_ds_StringMap());
	var $it0 = this.elements.keys();
	while( $it0.hasNext() ) {
		var elName = $it0.next();
		var elName1 = [elName];
		fancy_util_Dom.on(fancy_util_Dom.on(this.elements.get(elName1[0]),"mouseover",(function(elName1) {
			return function(_) {
				_g.selectItem(elName1[0]);
			};
		})(elName1)),"mouseout",(function() {
			return function(_1) {
				_g.selectItem();
			};
		})());
	}
	this.el = fancy_util_Dom.create("div." + this.classes.suggestionContainer + "." + this.classes.suggestionsClosed,null,[fancy_util_Dom.create("ul." + this.classes.suggestionList,null,(function($this) {
		var $r;
		var _g3 = [];
		var $it1 = $this.elements.iterator();
		while( $it1.hasNext() ) {
			var item = $it1.next();
			_g3.push(item);
		}
		$r = _g3;
		return $r;
	}(this)))]);
	this.parent.appendChild(this.el);
};
fancy_Suggestions.defaultFilterer = function(suggestion,search) {
	return suggestion.toLowerCase().indexOf(search.toLowerCase()) >= 0;
};
fancy_Suggestions.prototype = {
	filter: function(search) {
		var _g = this;
		this.filtered = this.suggestions.filter(function(_) {
			return _g.filterFn(_,search);
		});
		var _g1 = 0;
		var _g11 = this.suggestions;
		while(_g1 < _g11.length) {
			var sugg = _g11[_g1];
			++_g1;
			if(thx_Arrays.contains(this.filtered,sugg)) fancy_util_Dom.addClass(fancy_util_Dom.removeClass(this.elements.get(sugg),this.classes.suggestionItemFail),this.classes.suggestionItemMatch); else {
				fancy_util_Dom.addClass(fancy_util_Dom.removeClass(this.elements.get(sugg),this.classes.suggestionItemMatch),this.classes.suggestionItemFail);
				if(this.selected == sugg) {
					fancy_util_Dom.removeClass(this.elements.get(sugg),this.classes.suggestionItemSelected);
					this.selected = "";
				}
			}
		}
	}
	,open: function() {
		this.isOpen = true;
		fancy_util_Dom.addClass(fancy_util_Dom.removeClass(this.el,this.classes.suggestionsClosed),this.classes.suggestionsOpen);
	}
	,close: function() {
		this.isOpen = false;
		this.selectItem();
		fancy_util_Dom.addClass(fancy_util_Dom.removeClass(this.el,this.classes.suggestionsOpen),this.classes.suggestionsClosed);
	}
	,selectItem: function(key) {
		if(key == null) key = "";
		if(this.selected != "") fancy_util_Dom.removeClass(this.elements.get(this.selected),this.classes.suggestionItemSelected);
		this.selected = key;
		if(this.elements.get(this.selected) != null) fancy_util_Dom.addClass(this.elements.get(this.selected),this.classes.suggestionItemSelected);
	}
	,moveSelectionUp: function() {
		var currentIndex = HxOverrides.indexOf(this.filtered,this.selected,0);
		var targetIndex;
		if(currentIndex > 0) targetIndex = currentIndex - 1; else targetIndex = this.filtered.length - 1;
		this.selectItem(this.filtered[targetIndex]);
	}
	,moveSelectionDown: function() {
		var currentIndex = HxOverrides.indexOf(this.filtered,this.selected,0);
		var targetIndex;
		if(currentIndex + 1 == this.filtered.length) targetIndex = 0; else targetIndex = currentIndex + 1;
		this.selectItem(this.filtered[targetIndex]);
	}
};
var fancy_util_Dom = function() { };
fancy_util_Dom.hasClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	return regex.match(el.className);
};
fancy_util_Dom.addClass = function(el,className) {
	if(!fancy_util_Dom.hasClass(el,className)) el.className += " " + className;
	return el;
};
fancy_util_Dom.removeClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	el.className = regex.replace(el.className,"");
	return el;
};
fancy_util_Dom.on = function(el,eventName,callback) {
	el.addEventListener(eventName,callback);
	return el;
};
fancy_util_Dom.create = function(name,attrs,children,textContent) {
	if(attrs == null) attrs = { };
	if(children == null) children = [];
	var classNames;
	if(Object.prototype.hasOwnProperty.call(attrs,"class")) classNames = Reflect.field(attrs,"class"); else classNames = "";
	var nameParts = name.split(".");
	name = nameParts.shift();
	if(nameParts.length > 0) classNames += " " + nameParts.join(" ");
	var el = window.document.createElement(name);
	var _g = 0;
	var _g1 = Reflect.fields(attrs);
	while(_g < _g1.length) {
		var att = _g1[_g];
		++_g;
		console.log(att);
		console.log(Reflect.field(attrs,att));
		el.setAttribute(att,Reflect.field(attrs,att));
	}
	el.className = classNames;
	var _g2 = 0;
	while(_g2 < children.length) {
		var child = children[_g2];
		++_g2;
		el.appendChild(child);
	}
	if(textContent != null) el.appendChild(window.document.createTextNode(textContent));
	return el;
};
var fancy_util_Keys = function() { };
var haxe_IMap = function() { };
var haxe_ds__$StringMap_StringMapIterator = function(map,keys) {
	this.map = map;
	this.keys = keys;
	this.index = 0;
	this.count = keys.length;
};
haxe_ds__$StringMap_StringMapIterator.prototype = {
	hasNext: function() {
		return this.index < this.count;
	}
	,next: function() {
		return this.map.get(this.keys[this.index++]);
	}
};
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,keys: function() {
		var _this = this.arrayKeys();
		return HxOverrides.iter(_this);
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) out.push(key);
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) out.push(key.substr(1));
			}
		}
		return out;
	}
	,iterator: function() {
		return new haxe_ds__$StringMap_StringMapIterator(this,this.arrayKeys());
	}
};
var thx_Arrays = function() { };
thx_Arrays.contains = function(array,element,eq) {
	if(null == eq) return HxOverrides.indexOf(array,element,0) >= 0; else {
		var _g1 = 0;
		var _g = array.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(eq(array[i],element)) return true;
		}
		return false;
	}
};
thx_Arrays.reduce = function(array,callback,initial) {
	return array.reduce(callback,initial);
};
var thx_Objects = function() { };
thx_Objects.combine = function(first,second) {
	var to = { };
	var _g = 0;
	var _g1 = Reflect.fields(first);
	while(_g < _g1.length) {
		var field = _g1[_g];
		++_g;
		Reflect.setField(to,field,Reflect.field(first,field));
	}
	var _g2 = 0;
	var _g11 = Reflect.fields(second);
	while(_g2 < _g11.length) {
		var field1 = _g11[_g2];
		++_g2;
		Reflect.setField(to,field1,Reflect.field(second,field1));
	}
	return to;
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
if(Array.prototype.filter == null) Array.prototype.filter = function(f1) {
	var a1 = [];
	var _g11 = 0;
	var _g2 = this.length;
	while(_g11 < _g2) {
		var i1 = _g11++;
		var e = this[i1];
		if(f1(e)) a1.push(e);
	}
	return a1;
};
var __map_reserved = {}

      // Production steps of ECMA-262, Edition 5, 15.4.4.21
      // Reference: http://es5.github.io/#x15.4.4.21
      if (!Array.prototype.reduce) {
        Array.prototype.reduce = function(callback /*, initialValue*/) {
          'use strict';
          if (this == null) {
            throw new TypeError('Array.prototype.reduce called on null or undefined');
          }
          if (typeof callback !== 'function') {
            throw new TypeError(callback + ' is not a function');
          }
          var t = Object(this), len = t.length >>> 0, k = 0, value;
          if (arguments.length == 2) {
            value = arguments[1];
          } else {
            while (k < len && ! k in t) {
              k++;
            }
            if (k >= len) {
              throw new TypeError('Reduce of empty array with no initial value');
            }
            value = t[k++];
          }
          for (; k < len; k++) {
            if (k in t) {
              value = callback(value, t[k], k, t);
            }
          }
          return value;
        };
      }
    ;
fancy_util_Keys.ESCAPE = 27;
fancy_util_Keys.UP = 38;
fancy_util_Keys.DOWN = 40;
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}});
