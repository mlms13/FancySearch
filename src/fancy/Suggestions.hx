package fancy;

import js.html.Element;
import haxe.ds.StringMap;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using fancy.util.Dom;

typedef FilterFunction = Array<String> -> String -> Array<String>;

typedef SelectionChooseFunction = String -> Void;

typedef SuggestionBoxClassNames = {
  suggestionContainer : String,
  suggestionsOpen : String,
  suggestionsClosed : String,
  suggestionList : String,
  suggestionsEmpty : String,
  suggestionItem : String,
  suggestionItemSelected : String,
};

typedef SuggestionOptions = {
  classes : SuggestionBoxClassNames,
  ?filterFn : FilterFunction,
  limit : Int,
  onChooseSelection : SelectionChooseFunction,
  parent : Element,
  ?suggestions : Array<String>,
};

class Suggestions {
  public var parent(default, null) : Element;
  public var classes(default, null) : SuggestionBoxClassNames;
  public var limit(default, null) : Int;
  public var onChooseSelection(default, null) : SelectionChooseFunction;
  public var suggestions(default, null) : Array<String>;
  public var filtered(default, null) : Array<String>;
  public var elements(default, null) : StringMap<Element>;
  public var selected(default, null) : String; // selected item in `filtered`
  public var filterFn : FilterFunction;
  public var isOpen : Bool;
  var el : Element;
  var list : Element;

  public function new(options : SuggestionOptions) {
    // defaults
    parent = options.parent;
    classes = options.classes;
    limit = options.limit;
    onChooseSelection = options.onChooseSelection;
    suggestions = options.suggestions != null ? options.suggestions : [];
    filtered = suggestions.copy();
    selected = '';
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    isOpen = false;
    elements = suggestions.reduce(function (acc : StringMap<Element>, curr) {
      acc.set(curr, Dom.create('li.${classes.suggestionItem}', curr));
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

    list = Dom.create(
      'ul.${classes.suggestionList}',
      [for (item in elements) item]
    );
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [list]);

    parent.appendChild(el);
  }

  public function filter(search : String) {
    filtered = filterFn(suggestions, search).slice(0, limit);
    list.empty();

    filtered.map.fn(list.appendChild(elements.get(_)));

    if (!filtered.contains(selected)) {
      selected = "";
    }

    if (filtered.length == 0) {
      el.addClass(classes.suggestionsEmpty);
    } else {
      el.removeClass(classes.suggestionsEmpty);
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

  static function defaultFilterer(suggestions : Array<String>, search : String) {
    search = search.toLowerCase();
    return suggestions
      .filter.fn(_.toLowerCase().indexOf(search) >= 0)
      .order(function (a, b) {
        var posA = a.toLowerCase().indexOf(search),
            posB = b.toLowerCase().indexOf(search);

        return if (posA == posB)
          if (a < b) -1 else if ( a > b ) 1 else 0;
        else
          posA - posB;
      });
  }
}
