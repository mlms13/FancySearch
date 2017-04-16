package fancy.search;

import dots.Dom;
import haxe.ds.Option;
import js.html.Element;
import fancy.search.FancySearchSettings;
import fancy.search.util.Types;
import thx.Options;

typedef SuggestionToString<T> = T -> String;
typedef DefaultFilterFn<T> = SuggestionToString<T> -> String -> T -> Bool;
typedef DefaultChooseSelectionFn<T> = SuggestionToString<T> -> js.html.InputElement -> Option<T> -> Void;

class FancySuggestionSettings<T> {
  public var alwaysSelected(default, null): Bool;
  public var limit(default, null): Int;
  public var filterFn(default, null): FilterFunction<T>;
  public var onChooseSelection: SelectionChooseFunction<T>;
  public var suggestions: Array<T>;
  public var searchLiteralPosition(default, null): LiteralPosition;
  public var searchLiteralPrefix(default, null): String;
  public var searchLiteralValue(default, null): js.html.InputElement -> String;
  public var showSearchLiteralItem(default, null): Bool;
  public var sortSuggestionsFn(default, null): Option<SortSuggestions<T>>;
  public var suggestionToElement(default, null): T -> Element;
  public var suggestionToString(default, null): T -> String;

  function new(alwaysSelected, limit, filterFn, onChoose, suggestions, literalPosition, literalPrefix, literalValue, showLiteral, sorter, suggToElement, suggToString) {
    this.alwaysSelected = alwaysSelected;
    this.limit = limit;
    this.filterFn = filterFn;
    this.onChooseSelection = onChoose;
    this.suggestions = suggestions;
    this.searchLiteralPosition = literalPosition;
    this.searchLiteralPrefix = literalPrefix;
    this.searchLiteralValue = literalValue;
    this.showSearchLiteralItem = showLiteral;
    this.sortSuggestionsFn = sorter;
    this.suggestionToElement = suggToElement;
    this.suggestionToString = suggToString;
  }

  public static function createFromOptions<T>(filterFn: DefaultFilterFn<T>, chooseFn: DefaultChooseSelectionFn<T>, classes: FancySearchClasses, ?opts: SuggestionOptions<T>): FancySuggestionSettings<T> {
    var toString = opts.suggestionToString != null ? opts.suggestionToString : function (t) return Std.string(t);

    return new FancySuggestionSettings(
      opts.alwaysSelected != null ? opts.alwaysSelected : false,
      opts.limit != null ? opts.limit : 5,
      opts.filterFn != null ? opts.filterFn : filterFn.bind(toString),
      opts.onChooseSelection != null ? opts.onChooseSelection : chooseFn.bind(toString),
      opts.suggestions != null ? opts.suggestions : [],
      opts.searchLiteralPosition != null ? opts.searchLiteralPosition : First,
      opts.searchLiteralPrefix != null ? opts.searchLiteralPrefix : "Search for: ",
      opts.searchLiteralValue != null ? opts.searchLiteralValue : function (inpt) return inpt.value,
      opts.showSearchLiteralItem != null ? opts.showSearchLiteralItem : false,
      Options.ofValue(opts.sortSuggestionsFn),
      opts.suggestionToElement != null ? opts.suggestionToElement :
        function (t) return Dom.create('span', ["class" => classes.suggestionHighlight], toString(t)),
      toString
    );
  }
}
