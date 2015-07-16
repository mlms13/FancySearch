package fancy;

import js.html.Element;
using thx.Functions;
using fancy.util.Dom;

typedef FilterFunction = String -> String -> Bool;

class Suggestions {
  var el : Element;

  public function new(parent : Element, suggestions : Array<String>, filter : FilterFunction) {
    el = Dom.create('div.fa-suggestion-container', [
      Dom.create('ul', suggestions.map.fn(Dom.create('li', _)))
    ]);

    parent.appendChild(el);
  }
}
