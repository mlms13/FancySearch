package fancy;

import js.html.Element;
using thx.Arrays;
using thx.Functions;
using fancy.util.Dom;

typedef FilterFunction = String -> String -> Bool;

typedef SuggestionBoxClassNames = {
  suggestionContainer : String,
  suggestionsOpen : String,
  suggestionsClosed : String,
  suggestionList : String,
  suggestionItem : String,
  suggestionItemMatch : String,
  suggestionItemFail : String
};

typedef SuggestionOptions = {
  parent : Element,
  classes : SuggestionBoxClassNames,
  ?suggestions : Array<String>,
  ?filterFn : FilterFunction,
};

class Suggestions {
  public var parent(default, null) : Element;
  public var classes(default, null) : SuggestionBoxClassNames;
  public var suggestions(default, null) : Array<String>;
  public var filtered(default, null) : Array<String>;
  public var elements(default, null) : Map<String, Element>;
  public var filterFn : FilterFunction;
  var el : Element;

  public function new(options : SuggestionOptions) {
    // defaults
    parent = options.parent;
    classes = options.classes;
    suggestions = options.suggestions != null ? options.suggestions : [];
    filtered = suggestions.copy();
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    elements = suggestions.reduce(function (acc : Map<String, Element>, curr) {
      acc.set(curr, Dom.create('li.${classes.suggestionItem}.${classes.suggestionItemMatch}', curr));
      return acc;
    }, new Map<String, Element>());

    // set up the dom
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [
      Dom.create(
        'ul.${classes.suggestionList}',
        [for (el in elements) el]
      )
    ]);

    parent.appendChild(el);
  }

  public function filter(search : String) {
    filtered = suggestions.filter.fn(filterFn(_, search));
    for (sugg in suggestions) {
      if (filtered.contains(sugg)) {
        elements[sugg]
          .removeClass(classes.suggestionItemFail)
          .addClass(classes.suggestionItemMatch);
      }
      else {
        elements[sugg]
          .removeClass(classes.suggestionItemMatch)
          .addClass(classes.suggestionItemFail);
      }
    }
  }

  public function open() {
    el.removeClass(classes.suggestionsClosed)
      .addClass(classes.suggestionsOpen);
  }

  public function close() {
    el.removeClass(classes.suggestionsOpen)
      .addClass(classes.suggestionsClosed);
  }



  static function defaultFilterer(suggestion : String, search : String) {
    return suggestion.indexOf(search) >= 0;
  }
}
