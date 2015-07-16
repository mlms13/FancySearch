package fancy.util;

import js.Browser.document as document;
import js.html.Element;
import js.html.Event;

class Dom {
  public static function addClass(el : Element, className : String) {
    el.className += ' $className';
  }

  public static function removeClass(el : Element, className : String) {
    var regex = new EReg('(?:^|\\s)($className)(?!\\S)', 'g');
    el.className = regex.replace(el.className, '');
  }

  public static function on(el : Element, eventName : String, callback : Event -> Void) {
    el.addEventListener(eventName, callback);
    // TODO: add fallback for older IE
  }

  public static function create(name : String, ?attrs : Dynamic, ?children : Array<Dynamic>) : Element {
    if (attrs == null) {
      attrs = {};
      children = [];
    } else if (children == null) {
      if (Std.is(attrs, Array))
        children = (attrs : Array<Dynamic>).copy();
      attrs = {};
    }

    var classNames = Reflect.hasField(attrs, 'class') ? Reflect.field(attrs, 'class') : '';
    var nameParts = name.split('.');
    name = nameParts.shift();

    classNames += ' ' + nameParts.join(' ');

    var el = document.createElement(name);
    for (att in Reflect.fields(attrs)) {
      el.setAttribute(att, Reflect.field(attrs, att));
    }

    el.className = classNames;

    for (child in children) {
      if (Std.is(child, Element))
        el.appendChild(child);
      else if (Std.is(child, String))
        el.appendChild(document.createTextNode(child));
    }

    return el;
  }
}
