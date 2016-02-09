package fancy.search;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using fancy.browser.Dom;
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
class Suggestions<T> {
  var opts : SuggestionOptions<T>;
  var classes : FancySearchClassNames;
  public var elements(default, null) : OrderedMap<String, Element>;
  public var selected(default, null) : String; // key of item in `filtered`
  public var isOpen(default, null) : Bool;
  var filtered : OrderedMap<String, T>;
  var el : Element;
  var list : Element;

  /**
    When you create an instance of `Search`, it comes with a public `list` field
    that is an instance of `Suggestions`. In most cases, you will not need to
    create an instance of `Suggestions` directly.
  **/
  public function new(options : SuggestionOptions<T>, classes : FancySearchClassNames) {
    // `Search` should really provide these things, but they aren't actually
    // required when `Search` is being given its options.
    if (options.parent == null || options.input == null) {
      throw "Cannot create `Suggestions` without input or parent element";
    }

    // defaults
    this.classes = classes;
    initializeOptions(options);
    selected = '';
    isOpen = false;
    filtered = OrderedMap.createString();

    // create all elements and set initial suggestions
    list = Dom.create('ul.${classes.suggestionList}');
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [list]);
    opts.parent.append(el);

    setSuggestions(opts.suggestions);
  }

  function initializeOptions(options : SuggestionOptions<T>) {
    this.opts = cast Objects.combine(({
      filterFn : defaultFilterer,
      sortSuggestionsFn : defaultSortSuggestions,
      highlightLettersFn : defaultHighlightLetters,
      limit : 5,
      onChooseSelection : defaultChooseSelection,
      showSearchLiteralItem : false,
      searchLiteralPosition : LiteralPosition.First,
      searchLiteralValue : function (inpt) return inpt.value,
      searchLiteralPrefix : "Search for: ",
      suggestions : [],
      suggestionToString : function (t) return Std.string(t),
    } : SuggestionOptions<T>), options);
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

  static function suggestionToString<T>(toString : T -> String, suggestion : T) : String {
    return toString(suggestion);
  }

  static function suggestionsToStrings<T>(toString : T -> String, suggestions : Array<T>) : Array<String> {
    return suggestions.map(suggestionToString.bind(toString));
  }

  function getLiteralItemIndex() : Int {
    return opts.searchLiteralPosition == Last ? elements.length - 1 : 0;
  }

  // returns `true` or `false` depending on whether the item was created
  function shouldCreateLiteral(literal : String) : Bool {
    return opts.showSearchLiteralItem && opts.suggestions
      .map(suggestionToString.bind(opts.suggestionToString))
      .map.fn(_.toLowerCase())
      .indexOf(literal.toLowerCase()) < 0;
  }

  function createLiteralItem(label : String, replaceExisting = true) {

    // if we're not supposed to show the "Search for <literal>" option or the
    // current search input exactly matches a suggestion, return
    if (!shouldCreateLiteral(label)) return;

    // otherwise, create a suggestion element with text like "Search for: foo"
    var literalPosition = getLiteralItemIndex(),
        el = createSuggestionItem(opts.searchLiteralPrefix + label, label);

    if (replaceExisting) {
      elements.removeAt(literalPosition);
    }

    elements.insert(literalPosition, label, el);
  }

  /**
    Allows you to modify the list of suggested items on the fly.
  **/
  public function setSuggestions(items: Array<T>) {
    opts.suggestions = items.distinct();

    elements = opts.suggestions.reduce(function (acc : OrderedMap<String, Element>, curr) {
      var stringified = suggestionToString(opts.suggestionToString, curr);
      acc.set(stringified, createSuggestionItem(stringified));
      return acc;
    }, OrderedMap.createString());

    createLiteralItem(opts.searchLiteralValue(opts.input).trim(), false);

    if (isOpen)
      filter(opts.input.value);
  }

  /**
    Filtering the list happens automatically when the search input is focused,
    as well as when its value changes. Filtering uses the provided filter
    function, then the DOM is updated accordingly.

    In many cases, you will not need to manually call `filter`, but this
    method may be useful if your list can be filtered by means outside of the
    FancySearch input.
  **/
  public function filter(search : String) {
    // transform search string to our liking
    // TODO: latinize? trim? expose all this to the user?
    search = search.toLowerCase();

    // call the provided filter function, iterating over the whole list
    filtered = opts.suggestions
      .filter(opts.filterFn.bind(opts.suggestionToString, search))
      .order(opts.sortSuggestionsFn.bind(opts.suggestionToString, search))
      .slice(0, opts.limit)
      .reduce(function (acc : OrderedMap<String, T>, curr : T) {
        acc.set(suggestionToString(opts.suggestionToString, curr), curr);
        return acc;
      }, OrderedMap.createString());

    var filteredStrings = filtered.keys().toArray(),
        wordParts = opts.highlightLettersFn(filteredStrings, search);

    filteredStrings.reducei(function (list : Element, str : String, index) {
      var listItem = elements.get(str).empty();

      // each filtered word has an array of ranges to highlight
      // first we sort them be start index, then we iterate over them,
      // splitting the suggestion into spans and strongs.
      // NOTE: for now, we expect your ranges to not overlap each other.
      wordParts[index].order.fn(_0.right - _1.right).map(function (range) {
        // if the highlighted range isn't at the beginning, span it
        if (range.left != 0)
          listItem.append(Dom.create('span', str.substr(0, range.left)));

        // if the range to highlight has a non-zero length, strong it
        if (range.right > 0)
          listItem.append(Dom.create('strong', str.substr(range.left, range.right)));

        // if the range didn't end at the end of the string, span the rest
        if (range.left + range.right < str.length)
          listItem.append(Dom.create('span', str.substr(range.right + range.left)));
      });

      list.append(listItem);
      return list;
    }, list.empty());

    if (!filtered.exists(selected)) {
      selected = null;
    }

    // replace the existing literal item, if the options request it
    // and add inject the literal search text as a key in `filtered`
    var literalValue = opts.searchLiteralValue(opts.input).trim();
    if (!search.isEmpty() && shouldCreateLiteral(literalValue)) {
      createLiteralItem(literalValue);
      var literalElement = elements.get(literalValue);

      filtered.insert(getLiteralItemIndex(), literalValue, null);
      list.insertAtIndex(literalElement, getLiteralItemIndex());
      if (selected.isEmpty()) selectItem(literalValue);
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
    Move the highlight class to a specific item. If no key is provided, this
    method clears the selection.
  **/
  public function selectItem(?key : String) {
    // if a selection already existed, clear it
    elements.iterator().map.fn(_.removeClass(classes.suggestionItemSelected));

    // set the selection to the current key
    selected = key;

    // and if there's a corresponding element for that key, select the element
    if (!selected.isEmpty() && elements.exists(selected))
      elements.get(selected).addClass(classes.suggestionItemSelected);
  }

  /**
    Move the selection highlight to the previous suggestion.
  **/
  public function moveSelectionUp() {
    var currentIndex = filtered.keys().toArray().indexOf(selected),
        targetIndex = currentIndex > 0 ? currentIndex - 1 : filtered.length - 1;

    selectItem(filtered.keyAt(targetIndex));
  }

  /**
    Move the selection highlight to the next suggestion.
  **/
  public function moveSelectionDown() {
    var currentIndex = filtered.keys().toArray().indexOf(selected),
        targetIndex = (currentIndex + 1) == filtered.length ? 0 : currentIndex + 1;

    selectItem(filtered.keyAt(targetIndex));
  }

  /**
    Triggers the provided or default function when a selected item has been
    chosen (e.g. ENTER key or mouse click).
  **/
  public function chooseSelectedItem() {
    opts.onChooseSelection(opts.suggestionToString, opts.input, filtered.exists(selected) && filtered.get(selected) != null ?
      Some(filtered.get(selected)) :
      None
    );
  }

  /**
    Allows overriding the `onChooseSelection` function at any time.
  **/
  public function setChooseSelection(fn : SelectionChooseFunction<T>) {
    opts.onChooseSelection = fn;
  }


  static function defaultChooseSelection<T>(toString : T -> String, input : InputElement, selection : Option<T>) {
    switch selection {
      case Some(value): input.value = suggestionToString(toString, value);
      case None: input.value = input.value;
    }

    input.blur();
  }

  static function defaultFilterer<T>(toString : T -> String, search : String, sugg : T) : Bool {
    return suggestionToString(toString, sugg).toLowerCase().indexOf(search) >= 0;
  }

  static function defaultSortSuggestions<T>(toString : T -> String, search : String, suggA : T, suggB : T) {
    var a = suggestionToString(toString, suggA),
        b = suggestionToString(toString, suggB),
        posA = a.toLowerCase().indexOf(search),
        posB = b.toLowerCase().indexOf(search);

    return if (posA == posB)
      if (a < b) -1 else if (a > b) 1 else 0;
    else
      posA - posB;
  }

  static function defaultHighlightLetters(filtered : Array<String>, search : String) {
    return filtered.map(function (str) {
      return str.indexOf(search) >= 0 ?
        [new Tuple2(str.toLowerCase().indexOf(search.toLowerCase()), search.length)] :
        [new Tuple2(0, 0)];
    });
  }
}
