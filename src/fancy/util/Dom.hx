package fancy.util;

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
}
