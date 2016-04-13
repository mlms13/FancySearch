package fancy.search;

import haxe.ds.Option;
import js.html.Element;
import js.html.Event;
import js.html.InputElement;
import js.html.Node;
using dots.Dom;
import fancy.search.util.Types;
using thx.Arrays;
using thx.Functions;
using thx.Iterators;
using thx.Nulls;
import thx.Objects;
using thx.OrderedMap;
using thx.Strings;
using thx.Tuple;
import dots.Html;

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
    this.opts = initializeOptions(options);
    isOpen = false;
    filtered = OrderedMap.createString();

    // create all elements and set initial suggestions
    list = Dom.create('ul.${classes.suggestionList}');
    el = Dom.create('div.${classes.suggestionContainer}.${classes.suggestionsClosed}', [list]);
    opts.parent.append(el);

    setSuggestions(opts.suggestions);
  }

  function initializeOptions(options : SuggestionOptions<T>) {
    var opts : SuggestionOptions<T> = {
      parent : options.parent,
      input : options.input
    };
    opts.filterFn = options.filterFn.or(defaultFilterer);
    opts.sortSuggestionsFn = options.sortSuggestionsFn.or(defaultSortSuggestions);
    opts.limit = options.limit.or(5);
    opts.alwaysSelected = options.alwaysSelected.or(false);
    opts.onChooseSelection = options.onChooseSelection.or(defaultChooseSelection);
    opts.showSearchLiteralItem = options.showSearchLiteralItem.or(false);
    opts.searchLiteralPosition = options.searchLiteralPosition.or(LiteralPosition.First);
    opts.searchLiteralValue = options.searchLiteralValue.or(function (inpt) return inpt.value);
    opts.searchLiteralPrefix = options.searchLiteralPrefix.or("Search for: ");
    opts.suggestions = options.suggestions.or([]);
    if(null == classes.suggestionHighlight)
      classes.suggestionHighlight = "fs-suggestion-highlight";
    if(null == classes.suggestionHighlighted)
      classes.suggestionHighlighted = "fs-suggestion-highlighted";
    opts.suggestionToString = options.suggestionToString.or(function (t) return Std.string(t));
    opts.suggestionToElement = options.suggestionToElement.or(function (t) return Dom.create('span.${classes.suggestionHighlight}', opts.suggestionToString(t)));
    return opts;
  }

  function createSuggestionItem(label : Element, key : String) : Element {
    var dom = Dom.create('li.${classes.suggestionItem}', [label]);
    dom.addEventListener('mouseover', function(_ : Event) selectItem(key));
    dom.addEventListener('mousedown', function(_ : Event) chooseSelectedItem());
    dom.addEventListener('mouseout',  function(_ : Event) selectItem()); // select none
    return dom;
  }

  function createSuggestionItemString(label : String, key : String) : Element
    return createSuggestionItem(Dom.create('span.${classes.suggestionHighlight}', label), key);

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
    if (!shouldCreateLiteral(genKeyForLiteral(label))) return;

    // otherwise, create a suggestion element with text like "Search for: foo"
    var literalPosition = getLiteralItemIndex(),
        el = createSuggestionItemString(opts.searchLiteralPrefix + label, genKeyForLiteral(label));

    if (replaceExisting) {
      elements.removeAt(literalPosition);
    }

    elements.insert(literalPosition, genKeyForLiteral(label), el);
  }

  function genKeyForLiteral(label : String)
    return ':$label';

  /**
    Allows you to modify the list of suggested items on the fly.
  **/
  public function setSuggestions(items: Array<T>) {
    opts.suggestions = items.distinct();

    elements = opts.suggestions.reduce(function (acc : OrderedMap<String, Element>, curr) {
      var node = opts.suggestionToElement(curr),
          key = genKey(curr),
          dom = createSuggestionItem(node, key);
      acc.set(key, dom);
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

  function genKey(v : T) : String {
    return haxe.Json.stringify(v);
  }

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
        acc.set(genKey(curr), curr);
        return acc;
      }, OrderedMap.createString());

    filtered.keys().reducei(function (list : Element, key, index) {
      var dom = highlight(dehighlight(elements.get(key)), search);
      return list.append(dom);
    }, list.empty());

    // replace the existing literal item, if the options request it
    // and add inject the literal search text as a key in `filtered`
    var literalValue = opts.searchLiteralValue(opts.input).trim(),
        createLiteral = shouldCreateLiteral(literalValue);

    if (!search.isEmpty() && createLiteral) {
      createLiteralItem(literalValue);
      var literalElement = elements.get(genKeyForLiteral(literalValue));

      filtered.insert(getLiteralItemIndex(), literalValue, null);
      list.insertAtIndex(literalElement, getLiteralItemIndex());
    }

    // if the previously selected item is no longer after filtering...
    if (!filtered.exists(selected)) {
      if (createLiteral)
        // ...select the literal, if we created it
        selectItem(literalValue);
      else if (opts.alwaysSelected)
        // ...or select the first item if we should always select _something_
        selectItem(filtered.keyAt(0));
      else
        // ...or select nothing at all
        selectItem();
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

  function highlight(dom : Element, search : String) : Element {
    if(search.isEmpty())
      return dom; // don't bother
    var elements = dom.querySelectorAll('.${classes.suggestionHighlight}'),
        parts = search
                  .split(" ")
                  .filter(function(v) { return v != ""; })
                  .map(thx.ERegs.escape),
        pattern = new EReg('(${parts.join("|")})', "i");
    for(el in elements)
      highlightElement(cast el, pattern);
    return dom;
  }

  function highlightElement(dom : Element, pattern : EReg) : Element {
    Dom.traverseTextNodes(dom, function(node) {
      var text = node.textContent;
      var fragment = js.Browser.document.createDocumentFragment();
      while(pattern.match(text)) {
        var left = pattern.matchedLeft();
        if(left != "" && left != null) {
          fragment.appendChild(js.Browser.document.createTextNode(left));
        }
        fragment.appendChild(Dom.create('strong.${classes.suggestionHighlighted}', pattern.matched(1)));
        text = pattern.matchedRight();
      }
      fragment.appendChild(js.Browser.document.createTextNode(text));
      node.parentNode.replaceChild(fragment, node);
    });
    Dom.flattenTextNodes(dom);
    return dom;
  }

  function dehighlight(dom : Element) : Element {
    var els = dom.querySelectorAll('strong.${classes.suggestionHighlighted}');
    for(el in els) {
      if(el.childNodes.length == 0) {
        // no content, just remove the container
        el.parentNode.removeChild(el);
      } else if(el.childNodes.length == 1) {
        // simply replace node for node
        el.parentNode.replaceChild(el.childNodes[0], el);
      } else {
        // create a document fragment and replace
        var fragment = js.Browser.document.createDocumentFragment();
        for(child in el.childNodes)
          fragment.appendChild(child);
        el.parentNode.replaceChild(fragment, el);
      }
    }
    Dom.flattenTextNodes(dom);
    return dom;
  }
}
