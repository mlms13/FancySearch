package fancy.search.util;

import js.Browser.document as document;
import js.html.Element;
import js.html.Event;

class Dom {
  public static function hasClass(el : Element, className : String) {
    var regex = new EReg('(?:^|\\s)($className)(?!\\S)', 'g');
    return regex.match(el.className);
  }

  public static function addClass(el : Element, className : String) {
    if (!hasClass(el, className))
      el.className += ' $className';
    return el;
  }

  public static function removeClass(el : Element, className : String) {
    var regex = new EReg('(?:^|\\s)($className)(?!\\S)', 'g');
    el.className = regex.replace(el.className, '');
    return el;
  }

  public static function on(el : Element, eventName : String, callback : Event -> Void) {
    el.addEventListener(eventName, callback);
    // TODO: add fallback for older IE
    return el;
  }

  public static function create(name : String, ?attrs : Dynamic<Dynamic>, ?children : Array<Element>, ?textContent : String) : Element {
    if (attrs == null) {
      attrs = {};
    }
    if (children == null) {
      children = [];
    }

    var classNames = Reflect.hasField(attrs, 'class') ? Reflect.field(attrs, 'class') : '';
    var nameParts = name.split('.');
    name = nameParts.shift();

    if (nameParts.length > 0)
      classNames += ' ' + nameParts.join(' ');

    var el = document.createElement(name);
    for (att in Reflect.fields(attrs)) {
      trace(att);
      trace(Reflect.field(attrs, att));
      el.setAttribute(att, Reflect.field(attrs, att));
    }

    el.className = classNames;

    for (child in children) {
      el.appendChild(child);
    }

    if (textContent != null) {
      el.appendChild(document.createTextNode(textContent));
    }

    return el;
  }

  public static function insertChildAtIndex(el : Element, child : Element, index : Int) {
    el.insertBefore(child, el.children[index]);
    return el;
  }

  public static function prependChild(el : Element, child : Element) {
    return insertChildAtIndex(el, child, 0);
  }

  public static function empty(el : Element) {
    while (el.firstChild != null) {
      el.removeChild(el.firstChild);
    }
    return el;
  }
}
