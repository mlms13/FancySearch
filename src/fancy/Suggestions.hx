package fancy;

import js.html.Element;
using thx.Functions;
using fancy.util.Dom;

typedef FilterFunction = String -> String -> Bool;

typedef SuggestionBoxClassNames = {
  suggestionContainer : String,
  suggestionsOpen : String,
  suggestionsClosed : String,
  suggestionList : String,
  suggestionItem : String
};

typedef SuggestionOptions = {
  parent : Element,
  classes : SuggestionBoxClassNames,
  ?suggestions : Array<String>,
  ?filter : FilterFunction,
};

class Suggestions {
  public var parent(default, null) : Element;
  public var classes(default, null) : SuggestionBoxClassNames;
  public var suggestions(default, null) : Array<String>;
  public var filter : FilterFunction;
  var el : Element;

  public function new(options : SuggestionOptions) {
    // defaults
    parent = options.parent;
    classes = options.classes;
    suggestions = options.suggestions != null ? options.suggestions : [];
    filter = options.filter != null ? options.filter : defaultFilterer;

    // set up the dom
    el = Dom.create('div.${classes.suggestionContainer}${classes.suggestionsClosed}', [
      Dom.create(
        'ul.${classes.suggestionList}',
        suggestions.map.fn(Dom.create('li${classes.suggestionItem}', _))
      )
    ]);

    parent.appendChild(el);
  }

  static function defaultFilterer(suggestion : String, search : String) {
    return suggestion.indexOf(search) >= 0;
  }
}
