package fancy.search;

import js.html.Element;
import js.html.InputElement;
using fancy.search.util.Dom;
import fancy.search.util.Types;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using thx.Objects;
using thx.OrderedMap;
using thx.Strings;
using thx.Tuple;

/**
  The `Suggestions` class owns the suggestion list and controls its behavior.
  Public methods exist to modify suggestions, show and hide the menu, move the
  selection and choose the selected option, filter on demand, and more.
**/
class Suggestions {
  var opts : SuggestionOptions;
  var classes : FancySearchClassNames;
  public var filtered(default, null) : Array<String>;
  public var elements(default, null) : OrderedMap<String, Element>;
  public var selected(default, null) : String; // selected item in `filtered`
  public var isOpen(default, null) : Bool;
  var el : Element;
  var list : Element;

  /**
    When you create an instance of `Search`, it comes with a public `list` field
    that is an instance of `Suggestions`. In most cases, you will not need to
    create an instance of `Suggestions` directly.
  **/
  public function new(options : SuggestionOptions, classes : FancySearchClassNames) {
    // `Search` should really provide these things, but they aren't actually
    // required when `Search` is being given its options.
    if (options.parent == null || options.input == null) {
      throw "Cannot create `Suggestions` without input or parent element";
    }

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
      searchLiteralPosition : LiteralPosition.First,
      searchLiteralValue : function (inpt) return inpt.value,
      searchLiteralPrefix : "Search for: ",
      suggestions : [],
    }, options);
  }

  function createSuggestionItem(label : String, ?value : String) : Element {
    if (value == null) value = label;
    var el = Dom.create('li.${classes.suggestionItem}', label);

    return el
      .on('mouseover', function (_) {
        selectItem(value);
      })
      .on('mousedown', function (_) {
        chooseSelectedItem();
      })
      .on('mouseout', function (_) {
        selectItem(); // select none
      });
  }

  function getLiteralItemIndex() : Int {
    return opts.searchLiteralPosition == Last ? elements.length - 1 : 0;
  }

  // returns `true` or `false` depending on whether the item was created
  function createLiteralItem(?replaceExisting = true) : Bool {
    var literalValue = opts.searchLiteralValue(opts.input).trim(),
        containsLiteral = opts.suggestions.map.fn(_.toLowerCase()).indexOf(literalValue.toLowerCase()) >= 0;

    // if we're supposed to show the "Search for <literal>" option and the
    // current search text doesn't exactly match a
    if (opts.showSearchLiteralItem && !containsLiteral) {
      var literalPosition = getLiteralItemIndex(),
          el = createSuggestionItem(opts.searchLiteralPrefix + literalValue, literalValue);

      if (replaceExisting) {
        elements.removeAt(literalPosition);
      }

      elements.insert(literalPosition, literalValue, el);
      return true;
    }
    return false;
  }

  /**
    `list.setSuggestions` allows you to modify the String list of suggested
    items on the fly.
  **/
  public function setSuggestions(s : Array<String>) {
    opts.suggestions = s.distinct();
    list.empty();

    elements = opts.suggestions.reduce(function (acc : OrderedMap<String, Element>, curr) {
      acc.set(curr, createSuggestionItem(curr));
      return acc;
    }, OrderedMap.createString());

    createLiteralItem(false);
  }

  /**
    Filtering the list happens automatically when the search input is focues, as
    well as when its value changes. Filtering happens using the provided filter
    function, then the DOM is updated accordingly.

    In many cases, you will not need to manually call `filter`, but this
    method may be useful if your list can be filtered by means outside of the
    FancySearch input.
  **/
  public function filter(search : String) {
    search = search.toLowerCase();
    filtered = opts.filterFn(opts.suggestions, search).slice(0, opts.limit);
    var wordParts = opts.highlightLettersFn(filtered.copy(), search);

    filtered.reducei(function (list, str, index) {
      var listItem = elements.get(str).empty();

      // each filtered word has an array of ranges to highlight
      // first we sort them be start index, then we iterate over them,
      // splitting the suggestion into spans and strongs.
      // NOTE: for now, we expect your ranges to not overlap each other.
      wordParts[index].order.fn(_0.right - _1.right).map(function (range) {
        // if the highlighted range isn't at the beginning, span it
        if (range.left != 0)
          listItem.appendChild(Dom.create('span', str.substr(0, range.left)));

        // if the range to highlight has a non-zero length, strong it
        if (range.right > 0)
          listItem.appendChild(Dom.create('strong', str.substr(range.left, range.right)));

        // if the range didn't end at the end of the string, span the rest
        if (range.left + range.right < str.length)
          listItem.appendChild(Dom.create('span', str.substr(range.right + range.left)));
      });

      list.appendChild(listItem);
      return list;
    }, list.empty());

    if (!filtered.contains(selected)) {
      selected = "";
    }

    // replace the existing literal item, if the options request it
    // and add inject the literal search text as a key in `filtered`
    if (search != '' && createLiteralItem()) {
      var literalValue = opts.searchLiteralValue(opts.input).trim(),
      literalElement = elements.get(literalValue);

      filtered.insert(getLiteralItemIndex(), literalValue);
      list.insertChildAtIndex(literalElement, getLiteralItemIndex());
      if (selected == "") selectItem(literalValue);
    }

    if (filtered.length == 0) {
      this.el.addClass(classes.suggestionsEmpty);
    } else {
      this.el.removeClass(classes.suggestionsEmpty);
    }
  }

  /**
    Show the suggestion list by changing its class.
  **/
  public function open() {
    isOpen = true;
    el.removeClass(classes.suggestionsClosed)
      .addClass(classes.suggestionsOpen);
  }

  /**
    Hide the suggestion list by changing its class.
  **/
  public function close() {
    isOpen = false;
    selectItem();
    el.removeClass(classes.suggestionsOpen)
      .addClass(classes.suggestionsClosed);
  }

  /**
    Move the selection highlight class to a specific item (found using the
    item's string key). If no key is provided, this method clears the selection.
  **/
  public function selectItem(?key : String = '') {
    // if a selection already existed, clear it
    elements.iterator().map.fn(_.removeClass(classes.suggestionItemSelected));

    // set the selection to the current key
    selected = key;

    // and if there's a corresponding element for that key, select the element
    if (key != '' && elements.get(selected) != null)
      elements.get(selected).addClass(classes.suggestionItemSelected);
  }

  /**
    Move the selection highlight to the previous suggestion.
  **/
  public function moveSelectionUp() {
    var currentIndex = filtered.indexOf(selected),
      targetIndex = currentIndex > 0 ? currentIndex - 1 : filtered.length - 1;

    selectItem(filtered[targetIndex]);
  }

  /**
    Move the selection highlight to the next suggestion.
  **/
  public function moveSelectionDown() {
    var currentIndex = filtered.indexOf(selected),
      targetIndex = (currentIndex + 1) == filtered.length ? 0 : currentIndex + 1;

    selectItem(filtered[targetIndex]);
  }

  /**
    Triggers the provided or default function when a selected item has been
    chosen (e.g. ENTER key or mouse click).
  **/
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
