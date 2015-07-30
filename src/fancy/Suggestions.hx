package fancy;

import js.html.Element;
import haxe.ds.StringMap;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using fancy.util.Dom;
using thx.Tuple;

typedef FilterFunction = Array<String> -> String -> Array<String>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<Tuple2<Int, Int>>>;
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
  ?highlightLettersFn : HighlightLetters,
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
  public var highlightLettersFn : HighlightLetters;
  public var isOpen : Bool;
  var el : Element;
  var list : Element;

  public function new(options : SuggestionOptions) {
    // defaults
    parent = options.parent;
    classes = options.classes;
    limit = options.limit;
    onChooseSelection = options.onChooseSelection;
    filtered = [];
    selected = '';
    filterFn = options.filterFn != null ? options.filterFn : defaultFilterer;
    highlightLettersFn = options.highlightLettersFn != null ?
      options.highlightLettersFn :
      defaultHighlightLetters;
    isOpen = false;

    // create all elements and set initial suggestions
    list = Dom.create('ul.${classes.suggestionList}');
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [list]);
    setSuggestions(options.suggestions != null ? options.suggestions : []);
    parent.appendChild(el);
  }

  public function setSuggestions(suggestions : Array<String>) {
    this.suggestions = suggestions;
    list.empty();

    elements = suggestions.reduce(function (acc : StringMap<Element>, curr) {
      acc.set(curr, Dom.create('li.${classes.suggestionItem}', curr));
      return acc;
    }, new StringMap<Element>());

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
  }

  public function filter(search : String) {
    search = search.toLowerCase();
    filtered = filterFn(suggestions, search).slice(0, limit);
    var wordParts = highlightLettersFn(filtered, search);

    filtered.reducei(function (list, str, index) {
      var el = elements.get(str).empty();

      // each filtered word has an array of ranges to highlight
      // first we sort them be start index, then we iterate over them,
      // splitting the suggestion into spans and strongs.
      // NOTE: for now, we expect your ranges to not overlap each other.
      wordParts[index].order.fn(_0.right - _1.right).map(function (range) {
        // if the highlighted range isn't at the beginning, span it
        if (range.left != 0)
          el.appendChild(Dom.create('span', str.substr(0, range.left)));

        // if the range to highlight has a non-zero length, strong it
        if (range.right > 0)
          el.appendChild(Dom.create('strong', str.substr(range.left, range.right)));

        // if the range didn't end at the end of the string, span the rest
        if (range.left + range.right < str.length)
          el.appendChild(Dom.create('span', str.substr(range.right + range.left)));
      });

      list.appendChild(el);
      return list;
    }, list.empty());

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

  static function defaultHighlightLetters(filtered : Array<String>, search :String) {
    return filtered.map.fn([new Tuple2(_.toLowerCase().indexOf(search), search.length)]);
  }
}
