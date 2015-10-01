package fancy;

import js.html.Element;
import js.html.InputElement;
import haxe.ds.StringMap;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using thx.OrderedMap;
using fancy.util.Dom;
using thx.Tuple;
using thx.Objects;

class Suggestions {
  var opts : SuggestionOptions;
  var classes : FancySearchClassNames;
  public var filtered(default, null) : Array<String>;
  public var elements(default, null) : OrderedMap<String, Element>;
  public var selected(default, null) : String; // selected item in `filtered`
  public var isOpen(default, null) : Bool;
  var el : Element;
  var list : Element;

  public function new(options : SuggestionOptions, classes : FancySearchClassNames) {
    // defaults
    this.classes = classes;
    initializeOptions(options);
    filtered = [];
    selected = '';
    isOpen = false;

    // create all elements and set initial suggestions
    list = Dom.create('ul.${classes.suggestionList}');
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [list]);
    opts.parent.appendChild(el);

    setSuggestions(opts.suggestions);
  }

  function initializeOptions(options : SuggestionOptions) {
    this.opts = Objects.merge({
      filterFn : defaultFilterer,
      highlightLettersFn : defaultHighlightLetters,
      limit : 5,
      onChooseSelection : defaultChooseSelection,
      showSearchLiteralItem : false,
      searchLiteralIndex : 0,
      searchLiteralValue : function (inpt) return inpt.value,
      searchLiteralPrefix : "Search for: ",
      suggestions : [],
    }, options);
  }

  function insertLiteralItem() {
    var literalValue = opts.searchLiteralValue(opts.input),
        containsLiteral = opts.suggestions.map.fn(_.toLowerCase()).indexOf(literalValue) >= 0;

    if (opts.showSearchLiteralItem && !containsLiteral) {
      elements.insert(
        opts.searchLiteralIndex,
        literalValue,
        Dom.create('li.${classes.suggestionItem}', opts.searchLiteralPrefix + literalValue)
      );
    }
  }

  public function setSuggestions(s : Array<String>) {
    opts.suggestions = s;
    list.empty();

    elements = opts.suggestions.reduce(function (acc : OrderedMap<String, Element>, curr) {
      acc.set(curr, Dom.create('li.${classes.suggestionItem}', curr));
      return acc;
    }, OrderedMap.createString());

    insertLiteralItem();

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
    filtered = opts.filterFn(opts.suggestions, search).slice(0, opts.limit);
    var wordParts = opts.highlightLettersFn(filtered, search);

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
    opts.onChooseSelection(opts.input, selected);
  }


  static function defaultChooseSelection(input : InputElement, selection : String) {
    input.value = selection;
    input.blur();
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
