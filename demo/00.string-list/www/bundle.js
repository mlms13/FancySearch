// Generated by Haxe
(function (console, $global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
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
	,__class__: EReg
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(len == null) len = s.length; else if(len < 0) {
		if(pos == 0) len = s.length + len; else return "";
	}
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	}
	return s.substr(pos,len);
};
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
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Main = function() { };
Main.__name__ = true;
Main.main = function() {
	var options = { minLength : 0, suggestionOptions : { suggestions : ["Apple","Banana","Barley","Black Bean","Carrot","Corn","Cucumber","Dates","Eggplant","Fava Beans","Kale","Lettuce","Lime","Lima Bean","Mango","Melon","Orange","Peach","Pear","Pepper","Potato","Radish","Spinach","Tomato","Turnip","Zucchini"], limit : 6, showSearchLiteralItem : true}};
	var search = fancy_Search.createFromSelector(".fancy-container input",options);
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
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
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
var fancy_Search = function(el,options) {
	this.input = el;
	this.opts = this.createDefaultOptions(options);
	this.opts.classes = this.createDefaultClasses(this.opts.classes);
	if(this.opts.suggestionOptions.input == null) this.opts.suggestionOptions.input = this.input;
	if(this.opts.suggestionOptions.parent == null) this.opts.suggestionOptions.parent = this.opts.container;
	this.opts.keys = thx_Objects.combine({ closeMenu : [fancy_browser_Keys.ESCAPE], selectionUp : [fancy_browser_Keys.UP], selectionDown : [fancy_browser_Keys.DOWN,fancy_browser_Keys.TAB], selectionChoose : [fancy_browser_Keys.ENTER]},this.opts.keys);
	this.clearBtn = fancy_browser_Dom.create("button." + this.opts.classes.clearButton,null,null,"×");
	fancy_browser_Dom.on(this.clearBtn,"mousedown",this.opts.onClearButtonClick);
	if(this.opts.clearBtn) fancy_browser_Dom.append(this.opts.container,this.clearBtn);
	this.list = new fancy_search_Suggestions(this.opts.suggestionOptions,this.opts.classes);
	fancy_browser_Dom.addClass(this.input,this.opts.classes.input);
	if(this.input.value.length < 1) fancy_browser_Dom.addClass(this.input,this.opts.classes.inputEmpty);
	fancy_browser_Dom.on(this.input,"focus",$bind(this,this.onSearchFocus));
	fancy_browser_Dom.on(this.input,"blur",$bind(this,this.onSearchBlur));
	fancy_browser_Dom.on(this.input,"input",$bind(this,this.onSearchInput));
	fancy_browser_Dom.on(this.input,"keydown",$bind(this,this.onSearchKeydown));
};
fancy_Search.__name__ = true;
fancy_Search.createFromSelector = function(selector,options) {
	return new fancy_Search(window.document.querySelector(selector),options);
};
fancy_Search.prototype = {
	createDefaultOptions: function(options) {
		return thx_Objects.combine({ classes : { }, keys : { }, minLength : 1, clearBtn : true, container : this.input.parentElement, onClearButtonClick : $bind(this,this.onClearButtonClick), suggestionOptions : { }},options == null?{ }:options);
	}
	,createDefaultClasses: function(classes) {
		return thx_Objects.combine({ input : "fs-search-input", inputEmpty : "fs-search-input-empty", inputLoading : "fs-search-input-loading", clearButton : "fs-clear-input-button", suggestionContainer : "fs-suggestion-container", suggestionsOpen : "fs-suggestion-container-open", suggestionsClosed : "fs-suggestion-container-closed", suggestionsEmpty : "fs-suggestion-container-empty", suggestionList : "fs-suggestion-list", suggestionItem : "fs-suggestion-item", suggestionItemSelected : "fs-suggestion-item-selected"},this.opts.classes);
	}
	,onSearchFocus: function(e) {
		this.filterUsingInputValue();
	}
	,onSearchBlur: function(e) {
		this.checkEmptyStatus();
		this.list.close();
	}
	,filterUsingInputValue: function() {
		this.list.filter(this.input.value);
		if(this.input.value.length >= this.opts.minLength) this.list.open(); else this.list.close();
	}
	,checkEmptyStatus: function() {
		if(this.input.value.length > 0) fancy_browser_Dom.removeClass(this.input,this.opts.classes.inputEmpty); else fancy_browser_Dom.addClass(this.input,this.opts.classes.inputEmpty);
	}
	,onSearchInput: function(e) {
		var _g = this;
		this.checkEmptyStatus();
		this.filterUsingInputValue();
		if(this.opts.populateSuggestions != null) {
			fancy_browser_Dom.addClass(this.input,this.opts.classes.inputLoading);
			thx_promise__$Promise_Promise_$Impl_$.always(thx_promise__$Promise_Promise_$Impl_$.success(this.opts.populateSuggestions(this.input.value),($_=this.list,$bind($_,$_.setSuggestions))),function() {
				fancy_browser_Dom.removeClass(_g.input,_g.opts.classes.inputLoading);
			});
		}
	}
	,onSearchKeydown: function(e) {
		var code;
		if(e.which != null) code = e.which; else code = e.keyCode;
		if(thx_Arrays.contains(this.opts.keys.closeMenu,code)) this.list.close(); else if(thx_Arrays.contains(this.opts.keys.selectionUp,code) && this.list.isOpen) {
			e.preventDefault();
			this.list.moveSelectionUp();
		} else if(thx_Arrays.contains(this.opts.keys.selectionDown,code) && this.list.isOpen) {
			e.preventDefault();
			this.list.moveSelectionDown();
		} else if(thx_Arrays.contains(this.opts.keys.selectionChoose,code) && !thx_Strings.isEmpty(this.list.selected)) this.list.chooseSelectedItem();
	}
	,onClearButtonClick: function(e) {
		e.preventDefault();
		this.input.value = "";
		this.filterUsingInputValue();
	}
	,__class__: fancy_Search
};
var fancy_browser_Dom = function() { };
fancy_browser_Dom.__name__ = true;
fancy_browser_Dom.hasClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	return regex.match(el.className);
};
fancy_browser_Dom.addClass = function(el,className) {
	if(!fancy_browser_Dom.hasClass(el,className)) el.className += " " + className;
	return el;
};
fancy_browser_Dom.removeClass = function(el,className) {
	var regex = new EReg("(?:^|\\s)(" + className + ")(?!\\S)","g");
	el.className = regex.replace(el.className,"");
	return el;
};
fancy_browser_Dom.on = function(el,eventName,callback) {
	el.addEventListener(eventName,callback);
	return el;
};
fancy_browser_Dom.create = function(name,attrs,children,textContent) {
	if(attrs == null) attrs = new haxe_ds_StringMap();
	if(children == null) children = [];
	var classNames;
	if(__map_reserved["class"] != null?attrs.existsReserved("class"):attrs.h.hasOwnProperty("class")) classNames = __map_reserved["class"] != null?attrs.getReserved("class"):attrs.h["class"]; else classNames = "";
	var nameParts = name.split(".");
	name = nameParts.shift();
	if(nameParts.length > 0) classNames += " " + nameParts.join(" ");
	var el = window.document.createElement(name);
	thx_Iterators.reduce(attrs.keys(),function(acc,key) {
		acc.setAttribute(key,__map_reserved[key] != null?attrs.getReserved(key):attrs.h[key]);
		return acc;
	},el);
	el.className = classNames;
	var _g = 0;
	while(_g < children.length) {
		var child = children[_g];
		++_g;
		el.appendChild(child);
	}
	if(textContent != null) el.appendChild(window.document.createTextNode(textContent));
	return el;
};
fancy_browser_Dom.insertAtIndex = function(el,child,index) {
	el.insertBefore(child,el.children[index]);
	return el;
};
fancy_browser_Dom.appendChild = function(el,child) {
	el.appendChild(child);
	return el;
};
fancy_browser_Dom.appendChildren = function(el,children) {
	return children.reduce(fancy_browser_Dom.appendChild,el);
};
fancy_browser_Dom.append = function(el,child,children) {
	if(child != null) fancy_browser_Dom.appendChild(el,child);
	return fancy_browser_Dom.appendChildren(el,children != null?children:[]);
};
fancy_browser_Dom.empty = function(el) {
	while(el.firstChild != null) el.removeChild(el.firstChild);
	return el;
};
var fancy_browser_Keys = function() { };
fancy_browser_Keys.__name__ = true;
var fancy_search_Suggestions = function(options,classes) {
	if(options.parent == null || options.input == null) throw new js__$Boot_HaxeError("Cannot create `Suggestions` without input or parent element");
	this.classes = classes;
	this.opts = this.initializeOptions(options);
	this.isOpen = false;
	var inst = new thx_StringOrderedMap();
	this.filtered = inst;
	this.list = fancy_browser_Dom.create("ul." + classes.suggestionList);
	this.el = fancy_browser_Dom.create("div." + classes.suggestionContainer + "." + classes.suggestionsClosed,null,[this.list]);
	fancy_browser_Dom.append(this.opts.parent,this.el);
	this.setSuggestions(this.opts.suggestions);
};
fancy_search_Suggestions.__name__ = true;
fancy_search_Suggestions.suggestionToString = function(toString,suggestion) {
	return toString(suggestion);
};
fancy_search_Suggestions.defaultChooseSelection = function(toString,input,selection) {
	switch(selection[1]) {
	case 0:
		var value = selection[2];
		input.value = fancy_search_Suggestions.suggestionToString(toString,value);
		break;
	case 1:
		input.value = input.value;
		break;
	}
	input.blur();
};
fancy_search_Suggestions.defaultFilterer = function(toString,search,sugg) {
	return fancy_search_Suggestions.suggestionToString(toString,sugg).toLowerCase().indexOf(search) >= 0;
};
fancy_search_Suggestions.defaultSortSuggestions = function(toString,search,suggA,suggB) {
	var a = fancy_search_Suggestions.suggestionToString(toString,suggA);
	var b = fancy_search_Suggestions.suggestionToString(toString,suggB);
	var posA = a.toLowerCase().indexOf(search);
	var posB = b.toLowerCase().indexOf(search);
	if(posA == posB) {
		if(a < b) return -1; else if(a > b) return 1; else return 0;
	} else return posA - posB;
};
fancy_search_Suggestions.defaultHighlightLetters = function(toString,search,item) {
	var str = toString(item).toLowerCase();
	if(str.indexOf(search) >= 0) return [(function($this) {
		var $r;
		var _0 = str.indexOf(search);
		$r = { _0 : _0, _1 : search.length};
		return $r;
	}(this))]; else return [{ _0 : 0, _1 : 0}];
};
fancy_search_Suggestions.prototype = {
	initializeOptions: function(options) {
		var opts = { parent : options.parent, input : options.input};
		var t;
		var _0 = options;
		var _1;
		if(null == _0) t = null; else if(null == (_1 = _0.filterFn)) t = null; else t = _1;
		if(t != null) opts.filterFn = t; else opts.filterFn = fancy_search_Suggestions.defaultFilterer;
		var t1;
		var _01 = options;
		var _11;
		if(null == _01) t1 = null; else if(null == (_11 = _01.sortSuggestionsFn)) t1 = null; else t1 = _11;
		if(t1 != null) opts.sortSuggestionsFn = t1; else opts.sortSuggestionsFn = fancy_search_Suggestions.defaultSortSuggestions;
		var t2;
		var _02 = options;
		var _12;
		if(null == _02) t2 = null; else if(null == (_12 = _02.highlightLettersFn)) t2 = null; else t2 = _12;
		if(t2 != null) opts.highlightLettersFn = t2; else opts.highlightLettersFn = fancy_search_Suggestions.defaultHighlightLetters;
		var t3;
		var _03 = options;
		var _13;
		if(null == _03) t3 = null; else if(null == (_13 = _03.limit)) t3 = null; else t3 = _13;
		if(t3 != null) opts.limit = t3; else opts.limit = 5;
		var t4;
		var _04 = options;
		var _14;
		if(null == _04) t4 = null; else if(null == (_14 = _04.onChooseSelection)) t4 = null; else t4 = _14;
		if(t4 != null) opts.onChooseSelection = t4; else opts.onChooseSelection = fancy_search_Suggestions.defaultChooseSelection;
		var t5;
		var _05 = options;
		var _15;
		if(null == _05) t5 = null; else if(null == (_15 = _05.showSearchLiteralItem)) t5 = null; else t5 = _15;
		if(t5 != null) opts.showSearchLiteralItem = t5; else opts.showSearchLiteralItem = false;
		var t6;
		var _06 = options;
		var _16;
		if(null == _06) t6 = null; else if(null == (_16 = _06.searchLiteralPosition)) t6 = null; else t6 = _16;
		if(t6 != null) opts.searchLiteralPosition = t6; else opts.searchLiteralPosition = fancy_search_util_LiteralPosition.First;
		var t7;
		var _07 = options;
		var _17;
		if(null == _07) t7 = null; else if(null == (_17 = _07.searchLiteralValue)) t7 = null; else t7 = _17;
		if(t7 != null) opts.searchLiteralValue = t7; else opts.searchLiteralValue = function(inpt) {
			return inpt.value;
		};
		var t8;
		var _08 = options;
		var _18;
		if(null == _08) t8 = null; else if(null == (_18 = _08.searchLiteralPrefix)) t8 = null; else t8 = _18;
		if(t8 != null) opts.searchLiteralPrefix = t8; else opts.searchLiteralPrefix = "Search for: ";
		var t9;
		var _09 = options;
		var _19;
		if(null == _09) t9 = null; else if(null == (_19 = _09.suggestions)) t9 = null; else t9 = _19;
		if(t9 != null) opts.suggestions = t9; else opts.suggestions = [];
		var t10;
		var _010 = options;
		var _110;
		if(null == _010) t10 = null; else if(null == (_110 = _010.suggestionToString)) t10 = null; else t10 = _110;
		if(t10 != null) opts.suggestionToString = t10; else opts.suggestionToString = function(t11) {
			return Std.string(t11);
		};
		return opts;
	}
	,createSuggestionItem: function(label,value) {
		var _g = this;
		if(value == null) value = label;
		var el = fancy_browser_Dom.create("li." + this.classes.suggestionItem,null,null,label);
		return fancy_browser_Dom.on(fancy_browser_Dom.on(fancy_browser_Dom.on(el,"mouseover",function(_) {
			_g.selectItem(value);
		}),"mousedown",function(_1) {
			_g.chooseSelectedItem();
		}),"mouseout",function(_2) {
			_g.selectItem();
		});
	}
	,getLiteralItemIndex: function() {
		if(this.opts.searchLiteralPosition == fancy_search_util_LiteralPosition.Last) return this.elements.length - 1; else return 0;
	}
	,shouldCreateLiteral: function(literal) {
		return this.opts.showSearchLiteralItem && (function($this) {
			var $r;
			var _this = $this.opts.suggestions.map((function(f,a1) {
				return function(a2) {
					return f(a1,a2);
				};
			})(fancy_search_Suggestions.suggestionToString,$this.opts.suggestionToString)).map(function(_) {
				return _.toLowerCase();
			});
			var x = literal.toLowerCase();
			$r = HxOverrides.indexOf(_this,x,0);
			return $r;
		}(this)) < 0;
	}
	,createLiteralItem: function(label,replaceExisting) {
		if(replaceExisting == null) replaceExisting = true;
		if(!this.shouldCreateLiteral(label)) return;
		var literalPosition = this.getLiteralItemIndex();
		var el = this.createSuggestionItem(this.opts.searchLiteralPrefix + label,label);
		if(replaceExisting) this.elements.removeAt(literalPosition);
		this.elements.insert(literalPosition,label,el);
	}
	,setSuggestions: function(items) {
		var _g = this;
		this.opts.suggestions = thx_Arrays.distinct(items);
		this.elements = thx_Arrays.reduce(this.opts.suggestions,function(acc,curr) {
			var stringified = fancy_search_Suggestions.suggestionToString(_g.opts.suggestionToString,curr);
			acc.set(stringified,_g.createSuggestionItem(stringified));
			return acc;
		},(function($this) {
			var $r;
			var inst = new thx_StringOrderedMap();
			$r = inst;
			return $r;
		}(this)));
		this.createLiteralItem(StringTools.trim(this.opts.searchLiteralValue(this.opts.input)),false);
		if(this.isOpen) this.filter(this.opts.input.value);
	}
	,filter: function(search) {
		var _g = this;
		search = search.toLowerCase();
		this.filtered = thx_Arrays.reduce(thx_Arrays.order(this.opts.suggestions.filter((function(f,a1,a2) {
			return function(a3) {
				return f(a1,a2,a3);
			};
		})(this.opts.filterFn,this.opts.suggestionToString,search)),(function(f1,a11,a21) {
			return function(a31,a4) {
				return f1(a11,a21,a31,a4);
			};
		})(this.opts.sortSuggestionsFn,this.opts.suggestionToString,search)).slice(0,this.opts.limit),function(acc,curr) {
			acc.set(fancy_search_Suggestions.suggestionToString(_g.opts.suggestionToString,curr),curr);
			return acc;
		},(function($this) {
			var $r;
			var inst = new thx_StringOrderedMap();
			$r = inst;
			return $r;
		}(this)));
		thx_Arrays.reducei(this.filtered.tuples(),function(list,pair,index) {
			var key = pair._0;
			var val = pair._1;
			var listItem = thx_Arrays.reduce(((function(_e) {
				return function(sort) {
					return thx_Arrays.order(_e,sort);
				};
			})(_g.opts.highlightLettersFn(_g.opts.suggestionToString,search,val)))(function(_0,_1) {
				return _0._1 - _1._1;
			}),function(acc1,range) {
				if(range._0 != 0) fancy_browser_Dom.append(acc1,fancy_browser_Dom.create("span",null,null,HxOverrides.substr(key,0,range._0)));
				if(range._1 > 0) fancy_browser_Dom.append(acc1,fancy_browser_Dom.create("strong",null,null,HxOverrides.substr(key,range._0,range._1)));
				if(range._0 + range._1 < key.length) fancy_browser_Dom.append(acc1,fancy_browser_Dom.create("span",null,null,HxOverrides.substr(key,range._1 + range._0,null)));
				return acc1;
			},fancy_browser_Dom.empty(_g.elements.get(key)));
			return fancy_browser_Dom.append(list,listItem);
		},fancy_browser_Dom.empty(this.list));
		if(!this.filtered.exists(this.selected)) this.selected = null;
		var literalValue = StringTools.trim(this.opts.searchLiteralValue(this.opts.input));
		if(!thx_Strings.isEmpty(search) && this.shouldCreateLiteral(literalValue)) {
			this.createLiteralItem(literalValue);
			var literalElement = this.elements.get(literalValue);
			this.filtered.insert(this.getLiteralItemIndex(),literalValue,null);
			fancy_browser_Dom.insertAtIndex(this.list,literalElement,this.getLiteralItemIndex());
			if(thx_Strings.isEmpty(this.selected)) this.selectItem(literalValue);
		}
		if(this.filtered.length == 0) fancy_browser_Dom.addClass(this.el,this.classes.suggestionsEmpty); else fancy_browser_Dom.removeClass(this.el,this.classes.suggestionsEmpty);
	}
	,open: function() {
		this.isOpen = true;
		fancy_browser_Dom.addClass(fancy_browser_Dom.removeClass(this.el,this.classes.suggestionsClosed),this.classes.suggestionsOpen);
	}
	,close: function() {
		this.isOpen = false;
		this.selectItem();
		fancy_browser_Dom.addClass(fancy_browser_Dom.removeClass(this.el,this.classes.suggestionsOpen),this.classes.suggestionsClosed);
	}
	,selectItem: function(key) {
		var _g = this;
		((function(_e) {
			return function(f) {
				return thx_Iterators.map(_e,f);
			};
		})(this.elements.iterator()))(function(_) {
			return fancy_browser_Dom.removeClass(_,_g.classes.suggestionItemSelected);
		});
		this.selected = key;
		if(!thx_Strings.isEmpty(this.selected) && this.elements.exists(this.selected)) fancy_browser_Dom.addClass(this.elements.get(this.selected),this.classes.suggestionItemSelected);
	}
	,moveSelectionUp: function() {
		var currentIndex;
		var _this = thx_Iterators.toArray(this.filtered.keys());
		currentIndex = HxOverrides.indexOf(_this,this.selected,0);
		var targetIndex;
		if(currentIndex > 0) targetIndex = currentIndex - 1; else targetIndex = this.filtered.length - 1;
		this.selectItem(this.filtered.keyAt(targetIndex));
	}
	,moveSelectionDown: function() {
		var currentIndex;
		var _this = thx_Iterators.toArray(this.filtered.keys());
		currentIndex = HxOverrides.indexOf(_this,this.selected,0);
		var targetIndex;
		if(currentIndex + 1 == this.filtered.length) targetIndex = 0; else targetIndex = currentIndex + 1;
		this.selectItem(this.filtered.keyAt(targetIndex));
	}
	,chooseSelectedItem: function() {
		this.opts.onChooseSelection(this.opts.suggestionToString,this.opts.input,this.filtered.exists(this.selected) && this.filtered.get(this.selected) != null?haxe_ds_Option.Some(this.filtered.get(this.selected)):haxe_ds_Option.None);
	}
	,__class__: fancy_search_Suggestions
};
var fancy_search_util_LiteralPosition = { __ename__ : true, __constructs__ : ["First","Last"] };
fancy_search_util_LiteralPosition.First = ["First",0];
fancy_search_util_LiteralPosition.First.toString = $estr;
fancy_search_util_LiteralPosition.First.__enum__ = fancy_search_util_LiteralPosition;
fancy_search_util_LiteralPosition.Last = ["Last",1];
fancy_search_util_LiteralPosition.Last.toString = $estr;
fancy_search_util_LiteralPosition.Last.__enum__ = fancy_search_util_LiteralPosition;
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
haxe_IMap.prototype = {
	__class__: haxe_IMap
};
var haxe_ds_Option = { __ename__ : true, __constructs__ : ["Some","None"] };
haxe_ds_Option.Some = function(v) { var $x = ["Some",0,v]; $x.__enum__ = haxe_ds_Option; $x.toString = $estr; return $x; };
haxe_ds_Option.None = ["None",1];
haxe_ds_Option.None.toString = $estr;
haxe_ds_Option.None.__enum__ = haxe_ds_Option;
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,exists: function(key) {
		if(__map_reserved[key] != null) return this.existsReserved(key);
		return this.h.hasOwnProperty(key);
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		if(__map_reserved[key] != null) {
			key = "$" + key;
			if(this.rh == null || !this.rh.hasOwnProperty(key)) return false;
			delete(this.rh[key]);
			return true;
		} else {
			if(!this.h.hasOwnProperty(key)) return false;
			delete(this.h[key]);
			return true;
		}
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
	,__class__: haxe_ds_StringMap
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = true;
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var js_html_compat_ArrayBuffer = function(a) {
	if((a instanceof Array) && a.__enum__ == null) {
		this.a = a;
		this.byteLength = a.length;
	} else {
		var len = a;
		this.a = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			this.a[i] = 0;
		}
		this.byteLength = len;
	}
};
js_html_compat_ArrayBuffer.__name__ = true;
js_html_compat_ArrayBuffer.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null?null:end - begin);
	var result = new ArrayBuffer(u.byteLength);
	var resultArray = new Uint8Array(result);
	resultArray.set(u);
	return result;
};
js_html_compat_ArrayBuffer.prototype = {
	slice: function(begin,end) {
		return new js_html_compat_ArrayBuffer(this.a.slice(begin,end));
	}
	,__class__: js_html_compat_ArrayBuffer
};
var js_html_compat_Uint8Array = function() { };
js_html_compat_Uint8Array.__name__ = true;
js_html_compat_Uint8Array._new = function(arg1,offset,length) {
	var arr;
	if(typeof(arg1) == "number") {
		arr = [];
		var _g = 0;
		while(_g < arg1) {
			var i = _g++;
			arr[i] = 0;
		}
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else if(js_Boot.__instanceof(arg1,js_html_compat_ArrayBuffer)) {
		var buffer = arg1;
		if(offset == null) offset = 0;
		if(length == null) length = buffer.byteLength - offset;
		if(offset == 0) arr = buffer.a; else arr = buffer.a.slice(offset,offset + length);
		arr.byteLength = arr.length;
		arr.byteOffset = offset;
		arr.buffer = buffer;
	} else if((arg1 instanceof Array) && arg1.__enum__ == null) {
		arr = arg1.slice();
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else throw new js__$Boot_HaxeError("TODO " + Std.string(arg1));
	arr.subarray = js_html_compat_Uint8Array._subarray;
	arr.set = js_html_compat_Uint8Array._set;
	return arr;
};
js_html_compat_Uint8Array._set = function(arg,offset) {
	var t = this;
	if(js_Boot.__instanceof(arg.buffer,js_html_compat_ArrayBuffer)) {
		var a = arg;
		if(arg.byteLength + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g1 = 0;
		var _g = arg.byteLength;
		while(_g1 < _g) {
			var i = _g1++;
			t[i + offset] = a[i];
		}
	} else if((arg instanceof Array) && arg.__enum__ == null) {
		var a1 = arg;
		if(a1.length + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g11 = 0;
		var _g2 = a1.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1 + offset] = a1[i1];
		}
	} else throw new js__$Boot_HaxeError("TODO");
};
js_html_compat_Uint8Array._subarray = function(start,end) {
	var t = this;
	var a = js_html_compat_Uint8Array._new(t.slice(start,end));
	a.byteOffset = start;
	return a;
};
var thx_Arrays = function() { };
thx_Arrays.__name__ = true;
thx_Arrays.any = function(arr,predicate) {
	var $it0 = HxOverrides.iter(arr);
	while( $it0.hasNext() ) {
		var element = $it0.next();
		if(predicate(element)) return true;
	}
	return false;
};
thx_Arrays.contains = function(array,element,eq) {
	if(null == eq) return thx__$ReadonlyArray_ReadonlyArray_$Impl_$.indexOf(array,element) >= 0; else {
		var _g1 = 0;
		var _g = array.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(eq(array[i],element)) return true;
		}
		return false;
	}
};
thx_Arrays.distinct = function(array,predicate) {
	var result = [];
	if(array.length <= 1) return array.slice();
	if(null == predicate) predicate = thx_Functions.equality;
	var $it0 = HxOverrides.iter(array);
	while( $it0.hasNext() ) {
		var v = $it0.next();
		var v1 = [v];
		var keep = !thx_Arrays.any(result,(function(v1) {
			return function(r) {
				return predicate(r,v1[0]);
			};
		})(v1));
		if(keep) result.push(v1[0]);
	}
	return result;
};
thx_Arrays.order = function(array,sort) {
	var n = array.slice();
	n.sort(sort);
	return n;
};
thx_Arrays.reduce = function(array,callback,initial) {
	return array.reduce(callback,initial);
};
thx_Arrays.reducei = function(array,callback,initial) {
	return array.reduce(callback,initial);
};
var thx_Either = { __ename__ : true, __constructs__ : ["Left","Right"] };
thx_Either.Left = function(value) { var $x = ["Left",0,value]; $x.__enum__ = thx_Either; $x.toString = $estr; return $x; };
thx_Either.Right = function(value) { var $x = ["Right",1,value]; $x.__enum__ = thx_Either; $x.toString = $estr; return $x; };
var thx_Error = function() { };
thx_Error.__name__ = true;
thx_Error.__super__ = Error;
thx_Error.prototype = $extend(Error.prototype,{
	__class__: thx_Error
});
var thx_Functions = function() { };
thx_Functions.__name__ = true;
thx_Functions.equality = function(a,b) {
	return a == b;
};
var thx_Iterators = function() { };
thx_Iterators.__name__ = true;
thx_Iterators.map = function(it,f) {
	var acc = [];
	while( it.hasNext() ) {
		var v = it.next();
		acc.push(f(v));
	}
	return acc;
};
thx_Iterators.reduce = function(it,callback,initial) {
	thx_Iterators.map(it,function(v) {
		initial = callback(initial,v);
	});
	return initial;
};
thx_Iterators.toArray = function(it) {
	var elements = [];
	while( it.hasNext() ) {
		var element = it.next();
		elements.push(element);
	}
	return elements;
};
var thx_Objects = function() { };
thx_Objects.__name__ = true;
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
var thx_OrderedMapImpl = function(map) {
	this.map = map;
	this.arr = [];
	this.length = 0;
};
thx_OrderedMapImpl.__name__ = true;
thx_OrderedMapImpl.__interfaces__ = [haxe_IMap];
thx_OrderedMapImpl.prototype = {
	get: function(k) {
		return this.map.get(k);
	}
	,keyAt: function(index) {
		return this.arr[index];
	}
	,set: function(k,v) {
		if(!this.map.exists(k)) {
			this.arr.push(k);
			this.length++;
		}
		this.map.set(k,v);
	}
	,insert: function(index,k,v) {
		this.remove(k);
		this.arr.splice(index,0,k);
		this.map.set(k,v);
		this.length++;
	}
	,exists: function(k) {
		return this.map.exists(k);
	}
	,remove: function(k) {
		if(!this.map.exists(k)) return false;
		this.map.remove(k);
		HxOverrides.remove(this.arr,k);
		this.length--;
		return true;
	}
	,removeAt: function(index) {
		var key = this.arr[index];
		if(key == null) return false;
		this.map.remove(key);
		HxOverrides.remove(this.arr,key);
		this.length--;
		return true;
	}
	,keys: function() {
		return HxOverrides.iter(this.arr);
	}
	,iterator: function() {
		var _this = this.toArray();
		return HxOverrides.iter(_this);
	}
	,tuples: function() {
		var _g = this;
		return this.arr.map(function(key) {
			var _1 = _g.map.get(key);
			return { _0 : key, _1 : _1};
		});
	}
	,toArray: function() {
		var values = [];
		var _g = 0;
		var _g1 = this.arr;
		while(_g < _g1.length) {
			var k = _g1[_g];
			++_g;
			values.push(this.map.get(k));
		}
		return values;
	}
	,__class__: thx_OrderedMapImpl
};
var thx_StringOrderedMap = function() {
	thx_OrderedMapImpl.call(this,new haxe_ds_StringMap());
};
thx_StringOrderedMap.__name__ = true;
thx_StringOrderedMap.__super__ = thx_OrderedMapImpl;
thx_StringOrderedMap.prototype = $extend(thx_OrderedMapImpl.prototype,{
	__class__: thx_StringOrderedMap
});
var thx__$ReadonlyArray_ReadonlyArray_$Impl_$ = {};
thx__$ReadonlyArray_ReadonlyArray_$Impl_$.__name__ = true;
thx__$ReadonlyArray_ReadonlyArray_$Impl_$.indexOf = function(this1,el,eq) {
	if(null == eq) eq = thx_Functions.equality;
	var _g1 = 0;
	var _g = this1.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(eq(el,this1[i])) return i;
	}
	return -1;
};
var thx_Strings = function() { };
thx_Strings.__name__ = true;
thx_Strings.isEmpty = function(value) {
	return value == null || value == "";
};
var thx_promise_Future = function() { };
thx_promise_Future.__name__ = true;
thx_promise_Future.prototype = {
	then: function(handler) {
		this.handlers.push(handler);
		this.update();
		return this;
	}
	,update: function() {
		{
			var _g = this.state;
			switch(_g[1]) {
			case 1:
				break;
			case 0:
				var result = _g[2];
				var index = -1;
				while(++index < this.handlers.length) this.handlers[index](result);
				this.handlers = [];
				break;
			}
		}
	}
	,__class__: thx_promise_Future
};
var thx_promise__$Promise_Promise_$Impl_$ = {};
thx_promise__$Promise_Promise_$Impl_$.__name__ = true;
thx_promise__$Promise_Promise_$Impl_$.always = function(this1,handler) {
	return this1.then(function(_) {
		handler();
	});
};
thx_promise__$Promise_Promise_$Impl_$.either = function(this1,success,failure) {
	return this1.then(function(r) {
		switch(r[1]) {
		case 1:
			var value = r[2];
			success(value);
			break;
		case 0:
			var error = r[2];
			failure(error);
			break;
		}
	});
};
thx_promise__$Promise_Promise_$Impl_$.success = function(this1,success) {
	return thx_promise__$Promise_Promise_$Impl_$.either(this1,success,function(_) {
	});
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
if(Array.prototype.map == null) Array.prototype.map = function(f) {
	var a = [];
	var _g1 = 0;
	var _g = this.length;
	while(_g1 < _g) {
		var i = _g1++;
		a[i] = f(this[i]);
	}
	return a;
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
var ArrayBuffer = $global.ArrayBuffer || js_html_compat_ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js_html_compat_ArrayBuffer.sliceImpl;
var Uint8Array = $global.Uint8Array || js_html_compat_Uint8Array._new;

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
fancy_browser_Keys.TAB = 9;
fancy_browser_Keys.ENTER = 13;
fancy_browser_Keys.ESCAPE = 27;
fancy_browser_Keys.UP = 38;
fancy_browser_Keys.DOWN = 40;
js_Boot.__toStr = {}.toString;
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);