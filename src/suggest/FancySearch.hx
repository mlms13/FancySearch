package suggest;

import js.html.InputElement;

typedef FancySearchClassNames = {
  ?input : String
};

typedef FancySearchOptions = {
  ?suggestions : Array<String>,
  ?filterFn : String -> String -> Bool,
  ?classes : FancySearchClassNames
};

class FancySearch {
  public var suggestions(default, null) : Array<String>;
  public var filterFn(default, null) : String -> String -> Bool;
  public var classes(default, null) : FancySearchClassNames;

  public function new(el : InputElement, ?options : FancySearchOptions) {
    // initialize all of the options
    suggestions = options.suggestions != null ? options.suggestions : [];
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    classes = options.classes != null ? options.classes : {};
    classes.input = classes.input != null ? classes.input : 'fs-search-input';

    // apply classes
    el.classList.add(classes.input);
  }

  public static function defaultFilterer(suggestion : String, search : String) {
    return suggestion.indexOf(search) >= 0;
  }
}
