package fancy;

import js.html.InputElement;
import js.html.Event;
using thx.Objects;
using fancy.util.Dom;

typedef FancySearchClassNames = {
  ?input : String,
  ?suggestionContainer : String,
  ?suggestionsOpen : String,
  ?suggestionsClosed : String,
  ?suggestionList : String,
  ?suggestionItem : String,
};

typedef FancySearchOptions = {
  ?suggestions : Array<String>,
  ?filter : Suggestions.FilterFunction,
  ?classes : FancySearchClassNames
};

class Search {
  public var input : InputElement;
  public var suggList : Suggestions;
  public var classes : FancySearchClassNames;

  public function new(el : InputElement, ?options : FancySearchOptions) {
    // initialize all of the options
    input = el;
    options = options != null ? options : {};
    options.classes = options.classes != null ? options.classes : {};

    classes = Objects.merge({
      input : 'fs-search-input',
      suggestionContainer : 'fs-suggestion-container',
      suggestionsOpen : 'fs-suggestion-container-open',
      suggestionsClosed : 'fs-suggestion-container-closed',
      suggestionList : 'fs-suggestion-list',
      suggestionItem : 'fs-suggestion-item'
    }, options.classes);

    // create sibling elements
    suggList = new Suggestions({
      parent : input.parentElement,
      suggestions : options.suggestions,
      filter : options.filter,
      classes : {
        suggestionContainer : classes.suggestionContainer,
        suggestionsOpen : classes.suggestionsOpen,
        suggestionsClosed : classes.suggestionsClosed,
        suggestionList : classes.suggestionList,
        suggestionItem : classes.suggestionItem
      }
    });

    // apply classes
    input.addClass(classes.input);

    // apply event listeners
    input.on('focus', onSearchFocus);
    input.on('blur', onSearchBlur);
  }

  function onSearchFocus(e : Event) {
    suggList.open();
  }

  function onSearchBlur(e: Event) {
    suggList.close();
  }
}
