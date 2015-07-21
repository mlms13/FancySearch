package fancy;

import js.html.Element;
import haxe.ds.StringMap;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using fancy.util.Dom;

typedef FilterFunction = String -> String -> Bool;

typedef SelectionChooseFunction = String ->  Void;

typedef SuggestionBoxClassNames = {
  suggestionContainer : String,
  suggestionsOpen : String,
  suggestionsClosed : String,
  suggestionList : String,
  suggestionItem : String,
  suggestionItemMatch : String,
  suggestionItemFail : String,
  suggestionItemSelected : String,
};

typedef SuggestionOptions = {
  parent : Element,
  classes : SuggestionBoxClassNames,
  onChooseSelection : SelectionChooseFunction,
  ?suggestions : Array<String>,
  ?filterFn : FilterFunction,
};

class Suggestions {
  public var parent(default, null) : Element;
  public var classes(default, null) : SuggestionBoxClassNames;
  public var onChooseSelection(default, null) : SelectionChooseFunction;
  public var suggestions(default, null) : Array<String>;
  public var filtered(default, null) : Array<String>;
  public var elements(default, null) : StringMap<Element>;
  public var selected(default, null) : String; // selected item in `filtered`
  public var filterFn : FilterFunction;
  public var isOpen : Bool;
  var el : Element;

  public function new(options : SuggestionOptions) {
    // defaults
    parent = options.parent;
    classes = options.classes;
    onChooseSelection = options.onChooseSelection;
    suggestions = options.suggestions != null ? options.suggestions : [];
    filtered = suggestions.copy();
    selected = '';
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    isOpen = false;
    elements = suggestions.reduce(function (acc : StringMap<Element>, curr) {
      acc.set(curr, Dom.create('li.${classes.suggestionItem}.${classes.suggestionItemMatch}', curr));
      return acc;
    }, new StringMap<Element>());

    // set up the dom
    elements.keys().map(function (elName) {
      elements.get(elName)
        .on('mouseover', function (_) {
          selectItem(elName);
        })
        .on('mousedown', function (_) {
          chooseSelectedItem();
        })
        .on('mouseout', function (_) {
          selectItem(); // select none
        });
    });

    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [
      Dom.create(
        'ul.${classes.suggestionList}',
        [for (item in elements) item]
      )
    ]);

    parent.appendChild(el);
  }

  public function filter(search : String) {
    filtered = suggestions.filter.fn(filterFn(_, search));
    for (sugg in suggestions) {
      if (filtered.contains(sugg)) {
        elements.get(sugg)
          .removeClass(classes.suggestionItemFail)
          .addClass(classes.suggestionItemMatch);
      }
      else {
        elements.get(sugg)
          .removeClass(classes.suggestionItemMatch)
          .addClass(classes.suggestionItemFail);

        // unselect item if it is no longer part of the filtered list
        if (selected == sugg) {
          elements.get(sugg).removeClass(classes.suggestionItemSelected);
          selected = "";
        }
      }
    }
  }

  public function open() {
    isOpen = true;
    el.removeClass(classes.suggestionsClosed)
      .addClass(classes.suggestionsOpen);
  }

  public function close() {
    isOpen = false;
    selectItem();
    el.removeClass(classes.suggestionsOpen)
      .addClass(classes.suggestionsClosed);
  }

  public function selectItem(?key : String = '') {
    if (selected != '') {
      elements.get(selected).removeClass(classes.suggestionItemSelected);
    }

    selected = key;
    if (elements.get(selected) != null)
      elements.get(selected).addClass(classes.suggestionItemSelected);
  }

  public function moveSelectionUp() {
    var currentIndex = filtered.indexOf(selected),
      targetIndex = currentIndex > 0 ? currentIndex - 1 : filtered.length - 1;

    selectItem(filtered[targetIndex]);
  }

  public function moveSelectionDown() {
    var currentIndex = filtered.indexOf(selected),
      targetIndex = (currentIndex + 1) == filtered.length ? 0 : currentIndex + 1;

    selectItem(filtered[targetIndex]);
  }

  public function chooseSelectedItem() {
    onChooseSelection(selected);
  }

  static function defaultFilterer(suggestion : String, search : String) {
    return suggestion.toLowerCase().indexOf(search.toLowerCase()) >= 0;
  }
}
