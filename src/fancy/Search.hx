package fancy;

import js.html.InputElement;
import js.html.Event;
using fancy.util.Dom;

typedef FancySearchClassNames = {
  ?input : String,
  ?inputFocus : String
};

typedef FancySearchOptions = {
  ?suggestions : Array<String>,
  ?filterFn : String -> String -> Bool,
  ?classes : FancySearchClassNames
};

class Search {
  public var input : InputElement;
  public var suggestions(default, null) : Array<String>;
  public var filterFn(default, null) : String -> String -> Bool;
  public var classes(default, null) : FancySearchClassNames;

  public function new(el : InputElement, ?options : FancySearchOptions) {
    // initialize all of the options
    input = el;
    suggestions = options.suggestions != null ? options.suggestions : [];
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    classes = options.classes != null ? options.classes : {};
    classes.input = classes.input != null ? classes.input : 'fs-search-input';
    classes.inputFocus = classes.inputFocus != null ? classes.inputFocus : 'fs-search-input-focus';

    // apply classes
    input.addClass(classes.input);

    // apply event listeners
    input.on('focus', onSearchFocus);
    input.on('blur', onSearchBlur);
  }

  static function defaultFilterer(suggestion : String, search : String) {
    return suggestion.indexOf(search) >= 0;
  }

  function onSearchFocus(e : Event) {
    input.addClass(classes.inputFocus);
  }

  function onSearchBlur(e: Event) {
    input.removeClass(classes.inputFocus);
  }
}
