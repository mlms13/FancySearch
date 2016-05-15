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
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw new js__$Boot_HaxeError("EReg::matched");
	}
	,matchedLeft: function() {
		if(this.r.m == null) throw new js__$Boot_HaxeError("No string matched");
		return HxOverrides.substr(this.r.s,0,this.r.m.index);
	}
	,matchedRight: function() {
		if(this.r.m == null) throw new js__$Boot_HaxeError("No string matched");
		var sz = this.r.m.index + this.r.m[0].length;
		return HxOverrides.substr(this.r.s,sz,this.r.s.length - sz);
	}
	,matchedPos: function() {
		if(this.r.m == null) throw new js__$Boot_HaxeError("No string matched");
		return { pos : this.r.m.index, len : this.r.m[0].length};
	}
	,matchSub: function(s,pos,len) {
		if(len == null) len = -1;
		if(this.r.global) {
			this.r.lastIndex = pos;
			this.r.m = this.r.exec(len < 0?s:HxOverrides.substr(s,0,pos + len));
			var b = this.r.m != null;
			if(b) this.r.s = s;
			return b;
		} else {
			var b1 = this.match(len < 0?HxOverrides.substr(s,pos,null):HxOverrides.substr(s,pos,len));
			if(b1) {
				this.r.s = s;
				this.r.m.index += pos;
			}
			return b1;
		}
	}
	,map: function(s,f) {
		var offset = 0;
		var buf = new StringBuf();
		do {
			if(offset >= s.length) break; else if(!this.matchSub(s,offset)) {
				buf.add(HxOverrides.substr(s,offset,null));
				break;
			}
			var p = this.matchedPos();
			buf.add(HxOverrides.substr(s,offset,p.pos - offset));
			buf.add(f(this));
			if(p.len == 0) {
				buf.add(HxOverrides.substr(s,p.pos,1));
				offset = p.pos + 1;
			} else offset = p.pos + p.len;
		} while(this.r.global);
		if(!this.r.global && offset > 0 && offset < s.length) buf.add(HxOverrides.substr(s,offset,null));
		return buf.b;
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
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
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
		haxe_CallStack.lastException = e;
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
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = true;
StringBuf.prototype = {
	add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
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
var dots_AttributeType = { __ename__ : true, __constructs__ : ["BooleanAttribute","Property","BooleanProperty","OverloadedBooleanAttribute","NumericAttribute","PositiveNumericAttribute","SideEffectProperty"] };
dots_AttributeType.BooleanAttribute = ["BooleanAttribute",0];
dots_AttributeType.BooleanAttribute.toString = $estr;
dots_AttributeType.BooleanAttribute.__enum__ = dots_AttributeType;
dots_AttributeType.Property = ["Property",1];
dots_AttributeType.Property.toString = $estr;
dots_AttributeType.Property.__enum__ = dots_AttributeType;
dots_AttributeType.BooleanProperty = ["BooleanProperty",2];
dots_AttributeType.BooleanProperty.toString = $estr;
dots_AttributeType.BooleanProperty.__enum__ = dots_AttributeType;
dots_AttributeType.OverloadedBooleanAttribute = ["OverloadedBooleanAttribute",3];
dots_AttributeType.OverloadedBooleanAttribute.toString = $estr;
dots_AttributeType.OverloadedBooleanAttribute.__enum__ = dots_AttributeType;
dots_AttributeType.NumericAttribute = ["NumericAttribute",4];
dots_AttributeType.NumericAttribute.toString = $estr;
dots_AttributeType.NumericAttribute.__enum__ = dots_AttributeType;
dots_AttributeType.PositiveNumericAttribute = ["PositiveNumericAttribute",5];
dots_AttributeType.PositiveNumericAttribute.toString = $estr;
dots_AttributeType.PositiveNumericAttribute.__enum__ = dots_AttributeType;
dots_AttributeType.SideEffectProperty = ["SideEffectProperty",6];
dots_AttributeType.SideEffectProperty.toString = $estr;
dots_AttributeType.SideEffectProperty.__enum__ = dots_AttributeType;
var dots_Attributes = function() { };
dots_Attributes.__name__ = true;
dots_Attributes.setStringAttribute = function(el,name,value) {
	var prop = dots_Attributes.properties.get(name);
	if(null == value) {
		if(name == "value") el.setAttribute(name,""); else el.removeAttribute(name);
	} else if(prop == null) el.setAttribute(name,value); else switch(prop[1]) {
	case 0:case 3:case 4:case 5:
		el.setAttribute(name,value);
		break;
	case 1:case 2:case 6:
		el[name] = value;
		break;
	}
};
var dots_Dom = function() { };
dots_Dom.__name__ = true;
dots_Dom.addClass = function(el,className) {
	el.classList.add(className);
	return el;
};
dots_Dom.removeClass = function(el,className) {
	el.classList.remove(className);
	return el;
};
dots_Dom.on = function(el,eventName,handler) {
	el.addEventListener(eventName,handler);
	return el;
};
dots_Dom.create = function(name,attrs,children,textContent,doc) {
	var node = dots_SelectorParser.parseSelector(name,attrs);
	if(null == doc) doc = window.document;
	var el = doc.createElement(node.tag);
	var $it0 = node.attributes.keys();
	while( $it0.hasNext() ) {
		var key = $it0.next();
		dots_Attributes.setStringAttribute(el,key,node.attributes.get(key));
	}
	if(null != children) {
		var _g = 0;
		while(_g < children.length) {
			var child = children[_g];
			++_g;
			el.appendChild(child);
		}
	}
	if(null != textContent) el.appendChild(doc.createTextNode(textContent));
	return el;
};
dots_Dom.insertAtIndex = function(el,child,index) {
	el.insertBefore(child,el.children[index]);
	return el;
};
dots_Dom.appendChild = function(el,child) {
	el.appendChild(child);
	return el;
};
dots_Dom.appendChildren = function(el,children) {
	return thx_Arrays.reduce(children,dots_Dom.appendChild,el);
};
dots_Dom.append = function(el,child,children) {
	if(child != null) dots_Dom.appendChild(el,child);
	return dots_Dom.appendChildren(el,children != null?children:[]);
};
dots_Dom.empty = function(el) {
	while(el.firstChild != null) el.removeChild(el.firstChild);
	return el;
};
dots_Dom.flattenSiblingsAndChildren = function(node) {
	while(node != null) {
		if(node.nodeType == 1) dots_Dom.flattenSiblingsAndChildren(node.childNodes[0]); else if(node.nodeType == 3) while(null != node.nextSibling && node.nextSibling.nodeType == 3) {
			var a = node.textContent;
			var b = node.nextSibling.textContent;
			node.parentNode.removeChild(node.nextSibling);
			var t = window.document.createTextNode(a + b);
			node.parentNode.replaceChild(t,node);
			node = t;
		}
		node = node.nextSibling;
	}
};
dots_Dom.flattenTextNodes = function(dom) {
	dots_Dom.flattenSiblingsAndChildren(dom.childNodes[0]);
};
dots_Dom.traverseTextNodes = function(dom,f) {
	var collect = [];
	var perform;
	var perform1 = null;
	perform1 = function(dom1) {
		if(dom1.nodeType == 3) collect.push(dom1); else if(dom1.nodeType == 1) {
			var _g = 0;
			var _g1 = dom1.childNodes;
			while(_g < _g1.length) {
				var child = _g1[_g];
				++_g;
				perform1(child);
			}
		}
	};
	perform = perform1;
	perform(dom);
	var _g2 = 0;
	while(_g2 < collect.length) {
		var n = collect[_g2];
		++_g2;
		f(n);
	}
};
var dots_SelectorParser = function(selector) {
	this.selector = selector;
	this.index = 0;
};
dots_SelectorParser.__name__ = true;
dots_SelectorParser.parseSelector = function(selector,otherAttributes) {
	var result = new dots_SelectorParser(selector).parse();
	if(otherAttributes != null) result.attributes = dots_SelectorParser.mergeAttributes(result.attributes,otherAttributes);
	return result;
};
dots_SelectorParser.mergeAttributes = function(dest,other) {
	return thx_Iterators.reduce(other.keys(),function(acc,key) {
		var value;
		value = __map_reserved[key] != null?other.getReserved(key):other.h[key];
		if(key == "class" && (__map_reserved[key] != null?acc.existsReserved(key):acc.h.hasOwnProperty(key))) {
			var previousValue;
			previousValue = __map_reserved[key] != null?acc.getReserved(key):acc.h[key];
			value = "" + previousValue.toString() + " " + value.toString();
		}
		if(__map_reserved[key] != null) acc.setReserved(key,value); else acc.h[key] = value;
		return acc;
	},dest);
};
dots_SelectorParser.prototype = {
	parse: function() {
		var tag = this.gobbleTag();
		var attributes = this.gobbleAttributes();
		return { tag : tag, attributes : attributes};
	}
	,gobbleTag: function() {
		if(this.isIdentifierStart()) return this.gobbleIdentifier(); else return "div";
	}
	,gobbleAttributes: function() {
		var attributes = new haxe_ds_StringMap();
		while(this.index < this.selector.length) {
			var attribute = this.gobbleAttribute();
			if(attribute.key == "class" && (__map_reserved["class"] != null?attributes.existsReserved("class"):attributes.h.hasOwnProperty("class"))) {
				var previousClass = (__map_reserved["class"] != null?attributes.getReserved("class"):attributes.h["class"]).toString();
				attribute.value = "" + previousClass + " " + attribute.value.toString();
			}
			attributes.set(attribute.key,attribute.value);
		}
		return attributes;
	}
	,gobbleAttribute: function() {
		var _g = this["char"]();
		var unknown = _g;
		switch(_g) {
		case "#":
			return this.gobbleElementId();
		case ".":
			return this.gobbleElementClass();
		case "[":
			return this.gobbleElementAttribute();
		default:
			throw new thx_Error("unknown selector char \"" + unknown + "\" at pos " + this.index,null,{ fileName : "SelectorParser.hx", lineNumber : 79, className : "dots.SelectorParser", methodName : "gobbleAttribute"});
		}
	}
	,gobbleElementId: function() {
		this.gobbleChar("#");
		var id = this.gobbleIdentifier();
		return { key : "id", value : id};
	}
	,gobbleElementClass: function() {
		this.gobbleChar(".");
		var id = this.gobbleIdentifier();
		return { key : "class", value : id};
	}
	,gobbleElementAttribute: function() {
		this.gobbleChar("[");
		var key = this.gobbleIdentifier();
		this.gobbleChar("=");
		var value = this.gobbleUpTo("]");
		if(thx_Bools.canParse(value.toString())) {
			if(thx_Bools.parse(value.toString())) value = key; else value = null;
		}
		this.gobbleChar("]");
		return { key : key, value : value};
	}
	,gobbleIdentifier: function() {
		var result = [];
		result.push(this.gobbleChar());
		while(this.isIdentifierPart()) result.push(this.gobbleChar());
		return result.join("");
	}
	,gobbleChar: function(expecting,expectingAnyOf) {
		var c = this.selector.charAt(this.index++);
		if(expecting != null && expecting != c) throw new thx_Error("expecting " + expecting + " at position " + this.index + " of " + this.selector,null,{ fileName : "SelectorParser.hx", lineNumber : 122, className : "dots.SelectorParser", methodName : "gobbleChar"});
		if(expectingAnyOf != null && !thx_Arrays.contains(expectingAnyOf,c)) throw new thx_Error("expecting one of " + expectingAnyOf.join(", ") + " at position " + this.index + " of " + this.selector,null,{ fileName : "SelectorParser.hx", lineNumber : 125, className : "dots.SelectorParser", methodName : "gobbleChar"});
		return c;
	}
	,gobbleUpTo: function(stopChar) {
		var result = [];
		while(this["char"]() != stopChar) result.push(this.gobbleChar());
		return result.join("");
	}
	,isAlpha: function() {
		var c = this.code();
		return c >= 65 && c <= 90 || c >= 97 && c <= 122;
	}
	,isNumeric: function() {
		var c = this.code();
		return c >= 48 && c <= 57;
	}
	,isAny: function(cs) {
		var _g = 0;
		while(_g < cs.length) {
			var c = cs[_g];
			++_g;
			if(c == this["char"]()) return true;
		}
		return false;
	}
	,isIdentifierStart: function() {
		return this.isAlpha();
	}
	,isIdentifierPart: function() {
		return this.isAlpha() || this.isNumeric() || this.isAny(["_","-"]);
	}
	,'char': function() {
		return this.selector.charAt(this.index);
	}
	,code: function() {
		return HxOverrides.cca(this.selector,this.index);
	}
	,__class__: dots_SelectorParser
};
var fancy_Search = function(el,options) {
	this.input = el;
	this.opts = this.createDefaultOptions(options);
	this.opts.classes = this.createDefaultClasses(this.opts.classes);
	if(this.opts.suggestionOptions.input == null) this.opts.suggestionOptions.input = this.input;
	if(this.opts.suggestionOptions.parent == null) this.opts.suggestionOptions.parent = this.opts.container;
	this.opts.keys = thx_Objects.combine({ closeMenu : [27], selectionUp : [38], selectionDown : [40,9], selectionChoose : [13]},this.opts.keys);
	this.clearBtn = dots_Dom.create("button",(function($this) {
		var $r;
		var _g = new haxe_ds_StringMap();
		_g.set("class",$this.opts.classes.clearButton);
		$r = _g;
		return $r;
	}(this)),null,"×");
	dots_Dom.on(this.clearBtn,"mousedown",this.opts.onClearButtonClick);
	if(this.opts.clearBtn) dots_Dom.append(this.opts.container,this.clearBtn);
	this.list = new fancy_search_Suggestions(this.opts.suggestionOptions,this.opts.classes);
	dots_Dom.addClass(this.input,this.opts.classes.input);
	if(this.input.value.length < 1) dots_Dom.addClass(this.input,this.opts.classes.inputEmpty);
	dots_Dom.on(this.input,"focus",$bind(this,this.onSearchFocus));
	dots_Dom.on(this.input,"blur",$bind(this,this.onSearchBlur));
	dots_Dom.on(this.input,"input",$bind(this,this.onSearchInput));
	dots_Dom.on(this.input,"keydown",$bind(this,this.onSearchKeydown));
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
		if(this.input.value.length > 0) dots_Dom.removeClass(this.input,this.opts.classes.inputEmpty); else dots_Dom.addClass(this.input,this.opts.classes.inputEmpty);
	}
	,onSearchInput: function(e) {
		var _g = this;
		this.checkEmptyStatus();
		this.filterUsingInputValue();
		if(this.opts.populateSuggestions != null) {
			dots_Dom.addClass(this.input,this.opts.classes.inputLoading);
			thx_promise__$Promise_Promise_$Impl_$.always(thx_promise__$Promise_Promise_$Impl_$.success(this.polulateSuggestion(this.input.value),function(o) {
				if(o.query != _g.input.value) return;
				_g.list.setSuggestions(o.list);
			}),function() {
				dots_Dom.removeClass(_g.input,_g.opts.classes.inputLoading);
			});
		}
	}
	,polulateSuggestion: function(value) {
		return thx_promise__$Promise_Promise_$Impl_$.map(this.opts.populateSuggestions(value),function(result) {
			return { list : result, query : value};
		});
	}
	,onSearchKeydown: function(e) {
		e.stopPropagation();
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
var fancy_search_Suggestions = function(options,classes) {
	if(options.parent == null || options.input == null) throw new js__$Boot_HaxeError("Cannot create `Suggestions` without input or parent element");
	this.classes = classes;
	this.opts = this.initializeOptions(options);
	this.isOpen = false;
	var inst = new thx_StringOrderedMap();
	this.filtered = inst;
	this.list = dots_Dom.create("ul",(function($this) {
		var $r;
		var _g = new haxe_ds_StringMap();
		_g.set("class",classes.suggestionList);
		$r = _g;
		return $r;
	}(this)));
	this.el = dots_Dom.create("div",(function($this) {
		var $r;
		var _g1 = new haxe_ds_StringMap();
		_g1.set("class","" + classes.suggestionContainer + " " + classes.suggestionsClosed);
		$r = _g1;
		return $r;
	}(this)),[this.list]);
	dots_Dom.append(this.opts.parent,this.el);
	this.setSuggestions(this.opts.suggestions);
};
fancy_search_Suggestions.__name__ = true;
fancy_search_Suggestions.defaultChooseSelection = function(toString,input,selection) {
	switch(selection[1]) {
	case 0:
		var value = selection[2];
		input.value = toString(value);
		break;
	case 1:
		input.value = input.value;
		break;
	}
	input.blur();
};
fancy_search_Suggestions.defaultFilterer = function(toString,search,sugg) {
	return toString(sugg).toLowerCase().indexOf(search) >= 0;
};
fancy_search_Suggestions.prototype = {
	initializeOptions: function(options) {
		var _g1 = this;
		var opts = { parent : options.parent, input : options.input};
		opts.sortSuggestionsFn = options.sortSuggestionsFn;
		var t = (function() {
			var _0 = options;
			if(null == _0) return null;
			var _1 = _0.limit;
			if(null == _1) return null;
			return _1;
		})();
		if(t != null) opts.limit = t; else opts.limit = 5;
		var t1 = (function() {
			var _01 = options;
			if(null == _01) return null;
			var _11 = _01.alwaysSelected;
			if(null == _11) return null;
			return _11;
		})();
		if(t1 != null) opts.alwaysSelected = t1; else opts.alwaysSelected = false;
		var t2 = (function() {
			var _02 = options;
			if(null == _02) return null;
			var _12 = _02.showSearchLiteralItem;
			if(null == _12) return null;
			return _12;
		})();
		if(t2 != null) opts.showSearchLiteralItem = t2; else opts.showSearchLiteralItem = false;
		var t3 = (function() {
			var _03 = options;
			if(null == _03) return null;
			var _13 = _03.searchLiteralPosition;
			if(null == _13) return null;
			return _13;
		})();
		if(t3 != null) opts.searchLiteralPosition = t3; else opts.searchLiteralPosition = fancy_search_util_LiteralPosition.First;
		var t4 = (function() {
			var _04 = options;
			if(null == _04) return null;
			var _14 = _04.searchLiteralValue;
			if(null == _14) return null;
			return _14;
		})();
		if(t4 != null) opts.searchLiteralValue = t4; else opts.searchLiteralValue = function(inpt) {
			return inpt.value;
		};
		var t5 = (function() {
			var _05 = options;
			if(null == _05) return null;
			var _15 = _05.searchLiteralPrefix;
			if(null == _15) return null;
			return _15;
		})();
		if(t5 != null) opts.searchLiteralPrefix = t5; else opts.searchLiteralPrefix = "Search for: ";
		var t6 = (function() {
			var _06 = options;
			if(null == _06) return null;
			var _16 = _06.suggestions;
			if(null == _16) return null;
			return _16;
		})();
		if(t6 != null) opts.suggestions = t6; else opts.suggestions = [];
		if(null == this.classes.suggestionHighlight) this.classes.suggestionHighlight = "fs-suggestion-highlight";
		if(null == this.classes.suggestionHighlighted) this.classes.suggestionHighlighted = "fs-suggestion-highlighted";
		var t7 = (function() {
			var _07 = options;
			if(null == _07) return null;
			var _17 = _07.suggestionToString;
			if(null == _17) return null;
			return _17;
		})();
		if(t7 != null) opts.suggestionToString = t7; else opts.suggestionToString = function(t8) {
			return Std.string(t8);
		};
		var t9 = (function() {
			var _08 = options;
			if(null == _08) return null;
			var _18 = _08.onChooseSelection;
			if(null == _18) return null;
			return _18;
		})();
		if(t9 != null) opts.onChooseSelection = t9; else opts.onChooseSelection = (function(f,a1) {
			return function(a2,a3) {
				f(a1,a2,a3);
			};
		})(fancy_search_Suggestions.defaultChooseSelection,opts.suggestionToString);
		var t10 = (function() {
			var _09 = options;
			if(null == _09) return null;
			var _19 = _09.suggestionToElement;
			if(null == _19) return null;
			return _19;
		})();
		if(t10 != null) opts.suggestionToElement = t10; else opts.suggestionToElement = function(t11) {
			return dots_Dom.create("span",(function($this) {
				var $r;
				var _g = new haxe_ds_StringMap();
				_g.set("class",_g1.classes.suggestionHighlight);
				$r = _g;
				return $r;
			}(this)),null,opts.suggestionToString(t11));
		};
		var t12 = (function() {
			var _010 = options;
			if(null == _010) return null;
			var _110 = _010.filterFn;
			if(null == _110) return null;
			return _110;
		})();
		if(t12 != null) opts.filterFn = t12; else opts.filterFn = (function(f1,a11) {
			return function(a21,a31) {
				return f1(a11,a21,a31);
			};
		})(fancy_search_Suggestions.defaultFilterer,opts.suggestionToString);
		return opts;
	}
	,createSuggestionItem: function(label,key) {
		var _g1 = this;
		var dom = dots_Dom.create("li",(function($this) {
			var $r;
			var _g = new haxe_ds_StringMap();
			_g.set("class",$this.classes.suggestionItem);
			$r = _g;
			return $r;
		}(this)),[label]);
		dom.addEventListener("mouseover",function(_) {
			_g1.selectItem(key);
		});
		dom.addEventListener("mousedown",function(_1) {
			_g1.chooseSelectedItem();
		});
		dom.addEventListener("mouseout",function(_2) {
			_g1.selectItem();
		});
		return dom;
	}
	,createSuggestionItemString: function(label,key) {
		return this.createSuggestionItem(dots_Dom.create("span",(function($this) {
			var $r;
			var _g = new haxe_ds_StringMap();
			_g.set("class",$this.classes.suggestionHighlight);
			$r = _g;
			return $r;
		}(this)),null,label),key);
	}
	,getLiteralItemIndex: function() {
		if(this.opts.searchLiteralPosition == fancy_search_util_LiteralPosition.Last) return this.elements.length - 1; else return 0;
	}
	,shouldCreateLiteral: function(literal) {
		return this.opts.showSearchLiteralItem && (function($this) {
			var $r;
			var _this = $this.opts.suggestions.map($this.opts.suggestionToString).map(function(_) {
				return _.toLowerCase();
			});
			var x = literal.toLowerCase();
			$r = HxOverrides.indexOf(_this,x,0);
			return $r;
		}(this)) < 0;
	}
	,createLiteralItem: function(label,replaceExisting) {
		if(replaceExisting == null) replaceExisting = true;
		if(!this.shouldCreateLiteral(this.genKeyForLiteral(label))) return;
		var literalPosition = this.getLiteralItemIndex();
		var el = this.createSuggestionItemString(this.opts.searchLiteralPrefix + label,this.genKeyForLiteral(label));
		if(replaceExisting) this.elements.removeAt(literalPosition);
		this.elements.insert(literalPosition,this.genKeyForLiteral(label),el);
	}
	,setSuggestions: function(items) {
		var _g = this;
		this.opts.suggestions = thx_Arrays.distinct(items);
		this.elements = thx_Arrays.reduce(this.opts.suggestions,function(acc,curr) {
			var node = _g.opts.suggestionToElement(curr);
			var key = _g.genKey(curr);
			var dom = _g.createSuggestionItem(node,key);
			acc.set(key,dom);
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
		var temp = this.opts.suggestions.filter((function(f,a1) {
			return function(a2) {
				return f(a1,a2);
			};
		})(this.opts.filterFn,search));
		if(null != this.opts.sortSuggestionsFn) temp = thx_Arrays.order(temp,(function(f1,a11) {
			return function(a21,a3) {
				return f1(a11,a21,a3);
			};
		})(this.opts.sortSuggestionsFn,search));
		this.filtered = thx_Arrays.reduce(temp.slice(0,this.opts.limit),function(acc,curr) {
			acc.set(_g.genKey(curr),curr);
			return acc;
		},(function($this) {
			var $r;
			var inst = new thx_StringOrderedMap();
			$r = inst;
			return $r;
		}(this)));
		thx_Iterators.reducei(this.filtered.keys(),function(list,key,index) {
			var dom = _g.highlight(_g.dehighlight(_g.elements.get(key)),search);
			return dots_Dom.append(list,dom);
		},dots_Dom.empty(this.list));
		var literalValue = StringTools.trim(this.opts.searchLiteralValue(this.opts.input));
		var createLiteral = this.shouldCreateLiteral(literalValue);
		if(!thx_Strings.isEmpty(search) && createLiteral) {
			this.createLiteralItem(literalValue);
			var literalElement;
			var key1 = this.genKeyForLiteral(literalValue);
			literalElement = this.elements.get(key1);
			this.filtered.insert(this.getLiteralItemIndex(),literalValue,null);
			dots_Dom.insertAtIndex(this.list,literalElement,this.getLiteralItemIndex());
		}
		if(!this.filtered.exists(this.selected)) {
			if(createLiteral) this.selectItem(literalValue); else if(this.opts.alwaysSelected) this.selectItem(this.filtered.keyAt(0)); else this.selectItem();
		}
		if(this.filtered.length == 0) dots_Dom.addClass(this.el,this.classes.suggestionsEmpty); else dots_Dom.removeClass(this.el,this.classes.suggestionsEmpty);
	}
	,open: function() {
		this.isOpen = true;
		dots_Dom.addClass(dots_Dom.removeClass(this.el,this.classes.suggestionsClosed),this.classes.suggestionsOpen);
	}
	,close: function() {
		this.isOpen = false;
		this.selectItem();
		dots_Dom.addClass(dots_Dom.removeClass(this.el,this.classes.suggestionsOpen),this.classes.suggestionsClosed);
	}
	,selectItem: function(key) {
		var _g = this;
		((function(_e) {
			return function(f) {
				return thx_Iterators.map(_e,f);
			};
		})(this.elements.iterator()))(function(_) {
			_.classList.remove(_g.classes.suggestionItemSelected);
			return _;
		});
		this.selected = key;
		if(!thx_Strings.isEmpty(this.selected) && this.elements.exists(this.selected)) dots_Dom.addClass(this.elements.get(this.selected),this.classes.suggestionItemSelected);
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
		this.opts.onChooseSelection(this.opts.input,thx_Options.ofValue(this.filtered.get(this.selected)));
	}
	,highlight: function(dom,search) {
		if(thx_Strings.isEmpty(search)) return dom;
		var elements = dom.querySelectorAll("." + this.classes.suggestionHighlight.split(" ").join("."));
		var parts = search.split(" ").filter(function(v) {
			return v != "";
		}).map(thx_ERegs.escape);
		var pattern = new EReg("(" + parts.join("|") + ")","i");
		var _g = 0;
		while(_g < elements.length) {
			var el = elements[_g];
			++_g;
			this.highlightElement(el,pattern);
		}
		return dom;
	}
	,highlightElement: function(dom,pattern) {
		var _g1 = this;
		dots_Dom.traverseTextNodes(dom,function(node) {
			var text = node.textContent;
			var fragment = window.document.createDocumentFragment();
			while(pattern.match(text)) {
				var left = pattern.matchedLeft();
				if(left != "" && left != null) fragment.appendChild(window.document.createTextNode(left));
				fragment.appendChild(dots_Dom.create("strong",(function($this) {
					var $r;
					var _g = new haxe_ds_StringMap();
					_g.set("class",_g1.classes.suggestionHighlighted);
					$r = _g;
					return $r;
				}(this)),null,pattern.matched(1)));
				text = pattern.matchedRight();
			}
			fragment.appendChild(window.document.createTextNode(text));
			node.parentNode.replaceChild(fragment,node);
		});
		dots_Dom.flattenTextNodes(dom);
		return dom;
	}
	,dehighlight: function(dom) {
		var els = dom.querySelectorAll("strong." + this.classes.suggestionHighlighted.split(" ").join("."));
		var _g = 0;
		while(_g < els.length) {
			var el = els[_g];
			++_g;
			if(el.childNodes.length == 0) el.parentNode.removeChild(el); else if(el.childNodes.length == 1) el.parentNode.replaceChild(el.childNodes[0],el); else {
				var fragment = window.document.createDocumentFragment();
				var _g1 = 0;
				var _g2 = el.childNodes;
				while(_g1 < _g2.length) {
					var child = _g2[_g1];
					++_g1;
					fragment.appendChild(child);
				}
				el.parentNode.replaceChild(fragment,el);
			}
		}
		dots_Dom.flattenTextNodes(dom);
		return dom;
	}
	,genKey: function(v) {
		return JSON.stringify(v);
	}
	,genKeyForLiteral: function(label) {
		return ":" + label;
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
var haxe_StackItem = { __ename__ : true, __constructs__ : ["CFunction","Module","FilePos","Method","LocalFunction"] };
haxe_StackItem.CFunction = ["CFunction",0];
haxe_StackItem.CFunction.toString = $estr;
haxe_StackItem.CFunction.__enum__ = haxe_StackItem;
haxe_StackItem.Module = function(m) { var $x = ["Module",1,m]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.FilePos = function(s,file,line) { var $x = ["FilePos",2,s,file,line]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.Method = function(classname,method) { var $x = ["Method",3,classname,method]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
haxe_StackItem.LocalFunction = function(v) { var $x = ["LocalFunction",4,v]; $x.__enum__ = haxe_StackItem; $x.toString = $estr; return $x; };
var haxe_CallStack = function() { };
haxe_CallStack.__name__ = true;
haxe_CallStack.getStack = function(e) {
	if(e == null) return [];
	var oldValue = Error.prepareStackTrace;
	Error.prepareStackTrace = function(error,callsites) {
		var stack = [];
		var _g = 0;
		while(_g < callsites.length) {
			var site = callsites[_g];
			++_g;
			if(haxe_CallStack.wrapCallSite != null) site = haxe_CallStack.wrapCallSite(site);
			var method = null;
			var fullName = site.getFunctionName();
			if(fullName != null) {
				var idx = fullName.lastIndexOf(".");
				if(idx >= 0) {
					var className = HxOverrides.substr(fullName,0,idx);
					var methodName = HxOverrides.substr(fullName,idx + 1,null);
					method = haxe_StackItem.Method(className,methodName);
				}
			}
			stack.push(haxe_StackItem.FilePos(method,site.getFileName(),site.getLineNumber()));
		}
		return stack;
	};
	var a = haxe_CallStack.makeStack(e.stack);
	Error.prepareStackTrace = oldValue;
	return a;
};
haxe_CallStack.callStack = function() {
	try {
		throw new Error();
	} catch( e ) {
		haxe_CallStack.lastException = e;
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		var a = haxe_CallStack.getStack(e);
		a.shift();
		return a;
	}
};
haxe_CallStack.exceptionStack = function() {
	return haxe_CallStack.getStack(haxe_CallStack.lastException);
};
haxe_CallStack.toString = function(stack) {
	var b = new StringBuf();
	var _g = 0;
	while(_g < stack.length) {
		var s = stack[_g];
		++_g;
		b.b += "\nCalled from ";
		haxe_CallStack.itemToString(b,s);
	}
	return b.b;
};
haxe_CallStack.itemToString = function(b,s) {
	switch(s[1]) {
	case 0:
		b.b += "a C function";
		break;
	case 1:
		var m = s[2];
		b.b += "module ";
		if(m == null) b.b += "null"; else b.b += "" + m;
		break;
	case 2:
		var line = s[4];
		var file = s[3];
		var s1 = s[2];
		if(s1 != null) {
			haxe_CallStack.itemToString(b,s1);
			b.b += " (";
		}
		if(file == null) b.b += "null"; else b.b += "" + file;
		b.b += " line ";
		if(line == null) b.b += "null"; else b.b += "" + line;
		if(s1 != null) b.b += ")";
		break;
	case 3:
		var meth = s[3];
		var cname = s[2];
		if(cname == null) b.b += "null"; else b.b += "" + cname;
		b.b += ".";
		if(meth == null) b.b += "null"; else b.b += "" + meth;
		break;
	case 4:
		var n = s[2];
		b.b += "local function #";
		if(n == null) b.b += "null"; else b.b += "" + n;
		break;
	}
};
haxe_CallStack.makeStack = function(s) {
	if(s == null) return []; else if(typeof(s) == "string") {
		var stack = s.split("\n");
		if(stack[0] == "Error") stack.shift();
		var m = [];
		var rie10 = new EReg("^   at ([A-Za-z0-9_. ]+) \\(([^)]+):([0-9]+):([0-9]+)\\)$","");
		var _g = 0;
		while(_g < stack.length) {
			var line = stack[_g];
			++_g;
			if(rie10.match(line)) {
				var path = rie10.matched(1).split(".");
				var meth = path.pop();
				var file = rie10.matched(2);
				var line1 = Std.parseInt(rie10.matched(3));
				m.push(haxe_StackItem.FilePos(meth == "Anonymous function"?haxe_StackItem.LocalFunction():meth == "Global code"?null:haxe_StackItem.Method(path.join("."),meth),file,line1));
			} else m.push(haxe_StackItem.Module(StringTools.trim(line)));
		}
		return m;
	} else return s;
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = true;
haxe_IMap.prototype = {
	__class__: haxe_IMap
};
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe__$Int64__$_$_$Int64.__name__ = true;
haxe__$Int64__$_$_$Int64.prototype = {
	__class__: haxe__$Int64__$_$_$Int64
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
var haxe_io_Error = { __ename__ : true, __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe_io_Error.Blocked = ["Blocked",0];
haxe_io_Error.Blocked.toString = $estr;
haxe_io_Error.Blocked.__enum__ = haxe_io_Error;
haxe_io_Error.Overflow = ["Overflow",1];
haxe_io_Error.Overflow.toString = $estr;
haxe_io_Error.Overflow.__enum__ = haxe_io_Error;
haxe_io_Error.OutsideBounds = ["OutsideBounds",2];
haxe_io_Error.OutsideBounds.toString = $estr;
haxe_io_Error.OutsideBounds.__enum__ = haxe_io_Error;
haxe_io_Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe_io_Error; $x.toString = $estr; return $x; };
var haxe_io_FPHelper = function() { };
haxe_io_FPHelper.__name__ = true;
haxe_io_FPHelper.i32ToFloat = function(i) {
	var sign = 1 - (i >>> 31 << 1);
	var exp = i >>> 23 & 255;
	var sig = i & 8388607;
	if(sig == 0 && exp == 0) return 0.0;
	return sign * (1 + Math.pow(2,-23) * sig) * Math.pow(2,exp - 127);
};
haxe_io_FPHelper.floatToI32 = function(f) {
	if(f == 0) return 0;
	var af;
	if(f < 0) af = -f; else af = f;
	var exp = Math.floor(Math.log(af) / 0.6931471805599453);
	if(exp < -127) exp = -127; else if(exp > 128) exp = 128;
	var sig = Math.round((af / Math.pow(2,exp) - 1) * 8388608) & 8388607;
	return (f < 0?-2147483648:0) | exp + 127 << 23 | sig;
};
haxe_io_FPHelper.i64ToDouble = function(low,high) {
	var sign = 1 - (high >>> 31 << 1);
	var exp = (high >> 20 & 2047) - 1023;
	var sig = (high & 1048575) * 4294967296. + (low >>> 31) * 2147483648. + (low & 2147483647);
	if(sig == 0 && exp == -1023) return 0.0;
	return sign * (1.0 + Math.pow(2,-52) * sig) * Math.pow(2,exp);
};
haxe_io_FPHelper.doubleToI64 = function(v) {
	var i64 = haxe_io_FPHelper.i64tmp;
	if(v == 0) {
		i64.low = 0;
		i64.high = 0;
	} else {
		var av;
		if(v < 0) av = -v; else av = v;
		var exp = Math.floor(Math.log(av) / 0.6931471805599453);
		var sig;
		var v1 = (av / Math.pow(2,exp) - 1) * 4503599627370496.;
		sig = Math.round(v1);
		var sig_l = sig | 0;
		var sig_h = sig / 4294967296.0 | 0;
		i64.low = sig_l;
		i64.high = (v < 0?-2147483648:0) | exp + 1023 << 20 | sig_h;
	}
	return i64;
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
			haxe_CallStack.lastException = e;
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
var js_html_compat_DataView = function(buffer,byteOffset,byteLength) {
	this.buf = buffer;
	if(byteOffset == null) this.offset = 0; else this.offset = byteOffset;
	if(byteLength == null) this.length = buffer.byteLength - this.offset; else this.length = byteLength;
	if(this.offset < 0 || this.length < 0 || this.offset + this.length > buffer.byteLength) throw new js__$Boot_HaxeError(haxe_io_Error.OutsideBounds);
};
js_html_compat_DataView.__name__ = true;
js_html_compat_DataView.prototype = {
	getInt8: function(byteOffset) {
		var v = this.buf.a[this.offset + byteOffset];
		if(v >= 128) return v - 256; else return v;
	}
	,getUint8: function(byteOffset) {
		return this.buf.a[this.offset + byteOffset];
	}
	,getInt16: function(byteOffset,littleEndian) {
		var v = this.getUint16(byteOffset,littleEndian);
		if(v >= 32768) return v - 65536; else return v;
	}
	,getUint16: function(byteOffset,littleEndian) {
		if(littleEndian) return this.buf.a[this.offset + byteOffset] | this.buf.a[this.offset + byteOffset + 1] << 8; else return this.buf.a[this.offset + byteOffset] << 8 | this.buf.a[this.offset + byteOffset + 1];
	}
	,getInt32: function(byteOffset,littleEndian) {
		var p = this.offset + byteOffset;
		var a = this.buf.a[p++];
		var b = this.buf.a[p++];
		var c = this.buf.a[p++];
		var d = this.buf.a[p++];
		if(littleEndian) return a | b << 8 | c << 16 | d << 24; else return d | c << 8 | b << 16 | a << 24;
	}
	,getUint32: function(byteOffset,littleEndian) {
		var v = this.getInt32(byteOffset,littleEndian);
		if(v < 0) return v + 4294967296.; else return v;
	}
	,getFloat32: function(byteOffset,littleEndian) {
		return haxe_io_FPHelper.i32ToFloat(this.getInt32(byteOffset,littleEndian));
	}
	,getFloat64: function(byteOffset,littleEndian) {
		var a = this.getInt32(byteOffset,littleEndian);
		var b = this.getInt32(byteOffset + 4,littleEndian);
		return haxe_io_FPHelper.i64ToDouble(littleEndian?a:b,littleEndian?b:a);
	}
	,setInt8: function(byteOffset,value) {
		if(value < 0) this.buf.a[byteOffset + this.offset] = value + 128 & 255; else this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setUint8: function(byteOffset,value) {
		this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setInt16: function(byteOffset,value,littleEndian) {
		this.setUint16(byteOffset,value < 0?value + 65536:value,littleEndian);
	}
	,setUint16: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
		} else {
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p] = value & 255;
		}
	}
	,setInt32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,value,littleEndian);
	}
	,setUint32: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p++] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >>> 24;
		} else {
			this.buf.a[p++] = value >>> 24;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value & 255;
		}
	}
	,setFloat32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,haxe_io_FPHelper.floatToI32(value),littleEndian);
	}
	,setFloat64: function(byteOffset,value,littleEndian) {
		var i64 = haxe_io_FPHelper.doubleToI64(value);
		if(littleEndian) {
			this.setUint32(byteOffset,i64.low);
			this.setUint32(byteOffset,i64.high);
		} else {
			this.setUint32(byteOffset,i64.high);
			this.setUint32(byteOffset,i64.low);
		}
	}
	,__class__: js_html_compat_DataView
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
thx_Arrays.reduce = function(array,f,initial) {
	var $it0 = HxOverrides.iter(array);
	while( $it0.hasNext() ) {
		var v = $it0.next();
		initial = f(initial,v);
	}
	return initial;
};
var thx_Bools = function() { };
thx_Bools.__name__ = true;
thx_Bools.canParse = function(v) {
	var _g = v.toLowerCase();
	if(_g == null) return true; else switch(_g) {
	case "true":case "false":case "0":case "1":case "on":case "off":
		return true;
	default:
		return false;
	}
};
thx_Bools.parse = function(v) {
	var _g = v.toLowerCase();
	var v1 = _g;
	if(_g == null) return false; else switch(_g) {
	case "true":case "1":case "on":
		return true;
	case "false":case "0":case "off":
		return false;
	default:
		throw new js__$Boot_HaxeError("unable to parse \"" + v1 + "\"");
	}
};
var thx_ERegs = function() { };
thx_ERegs.__name__ = true;
thx_ERegs.escape = function(text) {
	return thx_ERegs.ESCAPE_PATTERN.map(text,function(ereg) {
		return "\\" + ereg.matched(1);
	});
};
var thx_Either = { __ename__ : true, __constructs__ : ["Left","Right"] };
thx_Either.Left = function(value) { var $x = ["Left",0,value]; $x.__enum__ = thx_Either; $x.toString = $estr; return $x; };
thx_Either.Right = function(value) { var $x = ["Right",1,value]; $x.__enum__ = thx_Either; $x.toString = $estr; return $x; };
var thx_Error = function(message,stack,pos) {
	Error.call(this,message);
	this.message = message;
	if(null == stack) {
		try {
			stack = haxe_CallStack.exceptionStack();
		} catch( e ) {
			haxe_CallStack.lastException = e;
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			stack = [];
		}
		if(stack.length == 0) try {
			stack = haxe_CallStack.callStack();
		} catch( e1 ) {
			haxe_CallStack.lastException = e1;
			if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
			stack = [];
		}
	}
	this.stackItems = stack;
	this.pos = pos;
};
thx_Error.__name__ = true;
thx_Error.fromDynamic = function(err,pos) {
	if(js_Boot.__instanceof(err,thx_Error)) return err;
	return new thx_error_ErrorWrapper("" + Std.string(err),err,null,pos);
};
thx_Error.__super__ = Error;
thx_Error.prototype = $extend(Error.prototype,{
	toString: function() {
		return this.message + "\nfrom: " + this.getPosition() + "\n\n" + this.stackToString();
	}
	,getPosition: function() {
		return this.pos.className + "." + this.pos.methodName + "() at " + this.pos.lineNumber;
	}
	,stackToString: function() {
		return haxe_CallStack.toString(this.stackItems);
	}
	,__class__: thx_Error
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
thx_Iterators.mapi = function(it,f) {
	var acc = [];
	var i = 0;
	while( it.hasNext() ) {
		var v = it.next();
		acc.push(f(v,i++));
	}
	return acc;
};
thx_Iterators.reduce = function(it,callback,initial) {
	var result = initial;
	while(it.hasNext()) result = callback(result,it.next());
	return result;
};
thx_Iterators.reducei = function(it,callback,initial) {
	thx_Iterators.mapi(it,function(v,i) {
		initial = callback(initial,v,i);
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
var thx_Options = function() { };
thx_Options.__name__ = true;
thx_Options.ofValue = function(value) {
	if(null == value) return haxe_ds_Option.None; else return haxe_ds_Option.Some(value);
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
var thx_error_ErrorWrapper = function(message,innerError,stack,pos) {
	thx_Error.call(this,message,stack,pos);
	this.innerError = innerError;
};
thx_error_ErrorWrapper.__name__ = true;
thx_error_ErrorWrapper.__super__ = thx_Error;
thx_error_ErrorWrapper.prototype = $extend(thx_Error.prototype,{
	__class__: thx_error_ErrorWrapper
});
var thx_promise_Future = function() {
	this.handlers = [];
	this.state = haxe_ds_Option.None;
};
thx_promise_Future.__name__ = true;
thx_promise_Future.create = function(handler) {
	var future = new thx_promise_Future();
	handler($bind(future,future.setState));
	return future;
};
thx_promise_Future.prototype = {
	then: function(handler) {
		this.handlers.push(handler);
		this.update();
		return this;
	}
	,setState: function(newstate) {
		{
			var _g = this.state;
			switch(_g[1]) {
			case 1:
				this.state = haxe_ds_Option.Some(newstate);
				break;
			case 0:
				var r = _g[2];
				throw new thx_Error("future was already \"" + Std.string(r) + "\", can't apply the new state \"" + Std.string(newstate) + "\"",null,{ fileName : "Future.hx", lineNumber : 121, className : "thx.promise.Future", methodName : "setState"});
				break;
			}
		}
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
				while(++index < this.handlers.length) {
					var handler = this.handlers[index];
					handler(result);
				}
				this.handlers = [];
				break;
			}
		}
	}
	,__class__: thx_promise_Future
};
var thx_promise__$Promise_Promise_$Impl_$ = {};
thx_promise__$Promise_Promise_$Impl_$.__name__ = true;
thx_promise__$Promise_Promise_$Impl_$.create = function(callback) {
	var future = thx_promise_Future.create(function(cb) {
		try {
			callback(function(v) {
				cb(thx_Either.Right(v));
			},function(e) {
				cb(thx_Either.Left(e));
			});
		} catch( e1 ) {
			haxe_CallStack.lastException = e1;
			if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
			cb(thx_Either.Left(thx_Error.fromDynamic(e1,{ fileName : "Promise.hx", lineNumber : 87, className : "thx.promise._Promise.Promise_Impl_", methodName : "create"})));
		}
	});
	return future;
};
thx_promise__$Promise_Promise_$Impl_$.createUnsafe = function(callback) {
	var future = thx_promise_Future.create(function(cb) {
		callback(function(v) {
			cb(thx_Either.Right(v));
		},function(e) {
			cb(thx_Either.Left(e));
		});
	});
	return future;
};
thx_promise__$Promise_Promise_$Impl_$.error = function(err) {
	return thx_promise__$Promise_Promise_$Impl_$.create(function(_,reject) {
		reject(err);
	});
};
thx_promise__$Promise_Promise_$Impl_$.value = function(v) {
	return thx_promise__$Promise_Promise_$Impl_$.create(function(resolve,_) {
		resolve(v);
	});
};
thx_promise__$Promise_Promise_$Impl_$.always = function(this1,handler) {
	var future = thx_promise_Future.create(function(cb) {
		this1.then(function(v) {
			try {
				handler();
				cb(v);
			} catch( e ) {
				haxe_CallStack.lastException = e;
				if (e instanceof js__$Boot_HaxeError) e = e.val;
				cb(thx_Either.Left(thx_Error.fromDynamic(e,{ fileName : "Promise.hx", lineNumber : 124, className : "thx.promise._Promise.Promise_Impl_", methodName : "always"})));
			}
		});
	});
	return future;
};
thx_promise__$Promise_Promise_$Impl_$.either = function(this1,success,failure) {
	return thx_promise__$Promise_Promise_$Impl_$.createUnsafe(function(resolve,reject) {
		this1.then(function(r) {
			try {
				switch(r[1]) {
				case 1:
					var v = r[2];
					success(v);
					resolve(v);
					break;
				case 0:
					var e = r[2];
					failure(e);
					reject(e);
					break;
				}
			} catch( e1 ) {
				haxe_CallStack.lastException = e1;
				if (e1 instanceof js__$Boot_HaxeError) e1 = e1.val;
				reject(thx_Error.fromDynamic(e1,{ fileName : "Promise.hx", lineNumber : 143, className : "thx.promise._Promise.Promise_Impl_", methodName : "either"}));
			}
		});
	});
};
thx_promise__$Promise_Promise_$Impl_$.flatMapEither = function(this1,success,failure) {
	return thx_promise__$Promise_Promise_$Impl_$.createUnsafe(function(resolve,reject) {
		this1.then(function(result) {
			switch(result[1]) {
			case 1:
				var v = result[2];
				try {
					thx_promise__$Promise_Promise_$Impl_$.either(success(v),resolve,reject);
				} catch( e ) {
					haxe_CallStack.lastException = e;
					if (e instanceof js__$Boot_HaxeError) e = e.val;
					reject(thx_Error.fromDynamic(e,{ fileName : "Promise.hx", lineNumber : 200, className : "thx.promise._Promise.Promise_Impl_", methodName : "flatMapEither"}));
				}
				break;
			case 0:
				var e1 = result[2];
				try {
					thx_promise__$Promise_Promise_$Impl_$.either(failure(e1),resolve,reject);
				} catch( e2 ) {
					haxe_CallStack.lastException = e2;
					if (e2 instanceof js__$Boot_HaxeError) e2 = e2.val;
					reject(thx_Error.fromDynamic(e2,{ fileName : "Promise.hx", lineNumber : 201, className : "thx.promise._Promise.Promise_Impl_", methodName : "flatMapEither"}));
				}
				break;
			}
		});
	});
};
thx_promise__$Promise_Promise_$Impl_$.map = function(this1,success) {
	return thx_promise__$Promise_Promise_$Impl_$.flatMapEither(this1,function(v) {
		return thx_promise__$Promise_Promise_$Impl_$.value(success(v));
	},function(err) {
		return thx_promise__$Promise_Promise_$Impl_$.error(err);
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
var DataView = $global.DataView || js_html_compat_DataView;
var Uint8Array = $global.Uint8Array || js_html_compat_Uint8Array._new;
dots_Attributes.properties = (function($this) {
	var $r;
	var _g = new haxe_ds_StringMap();
	_g.set("allowFullScreen",dots_AttributeType.BooleanAttribute);
	_g.set("async",dots_AttributeType.BooleanAttribute);
	_g.set("autoFocus",dots_AttributeType.BooleanAttribute);
	_g.set("autoPlay",dots_AttributeType.BooleanAttribute);
	_g.set("capture",dots_AttributeType.BooleanAttribute);
	_g.set("checked",dots_AttributeType.BooleanProperty);
	_g.set("cols",dots_AttributeType.PositiveNumericAttribute);
	_g.set("controls",dots_AttributeType.BooleanAttribute);
	_g.set("default",dots_AttributeType.BooleanAttribute);
	_g.set("defer",dots_AttributeType.BooleanAttribute);
	_g.set("disabled",dots_AttributeType.BooleanAttribute);
	_g.set("download",dots_AttributeType.OverloadedBooleanAttribute);
	_g.set("formNoValidate",dots_AttributeType.BooleanAttribute);
	_g.set("hidden",dots_AttributeType.BooleanAttribute);
	_g.set("loop",dots_AttributeType.BooleanAttribute);
	_g.set("multiple",dots_AttributeType.BooleanProperty);
	_g.set("muted",dots_AttributeType.BooleanProperty);
	_g.set("noValidate",dots_AttributeType.BooleanAttribute);
	_g.set("open",dots_AttributeType.BooleanAttribute);
	_g.set("readOnly",dots_AttributeType.BooleanAttribute);
	_g.set("required",dots_AttributeType.BooleanAttribute);
	_g.set("reversed",dots_AttributeType.BooleanAttribute);
	_g.set("rows",dots_AttributeType.PositiveNumericAttribute);
	_g.set("rowSpan",dots_AttributeType.NumericAttribute);
	_g.set("scoped",dots_AttributeType.BooleanAttribute);
	_g.set("seamless",dots_AttributeType.BooleanAttribute);
	_g.set("selected",dots_AttributeType.BooleanProperty);
	_g.set("size",dots_AttributeType.PositiveNumericAttribute);
	_g.set("span",dots_AttributeType.PositiveNumericAttribute);
	_g.set("start",dots_AttributeType.NumericAttribute);
	_g.set("value",dots_AttributeType.SideEffectProperty);
	_g.set("itemScope",dots_AttributeType.BooleanAttribute);
	$r = _g;
	return $r;
}(this));
haxe_io_FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe__$Int64__$_$_$Int64(0,0);
	$r = x;
	return $r;
}(this));
js_Boot.__toStr = {}.toString;
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
thx_ERegs.ESCAPE_PATTERN = new EReg("([-\\[\\]{}()*+?\\.,\\\\^$|# \t\r\n])","g");
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
