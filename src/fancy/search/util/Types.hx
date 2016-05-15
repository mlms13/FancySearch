package fancy.search.util;

import haxe.ds.Option;
import js.html.InputElement;
import js.html.Element;

/**
  The filter function is given the search string (value from the input), and
  a suggestion item to compare. It should return true if this item will be in
  the filtered list, and false to filter it out.

  The default filterer converts the suggestion to a lowercase string and checks
  for the full search string inside the suggestion string.
**/
typedef FilterFunction<T> = String -> T -> Bool;

/**
  The sort function is given a the original search string. It is also given two
  suggestion items, and it should return `-1`, `0`, or `1`, similar to most
  array order-by functions.

  The default sort function prefers suggestion strings with earlier occurences
  of the search string. If the occurence of the search string is equal, the
  suggestions are sorted alphabetically.
**/
typedef SortSuggestions<T> = String -> T -> T -> Int;

/**
  This function will be called when a suggestion item is chosen (either by mouse
  click, or the enter key, etc). It is given the actual input element and
  an Option of Some suggestion item or None.

  The default version of this function simply sets the input's value to the
  stringified suggestion item, then it blurs the input.
**/
typedef SelectionChooseFunction<T> = js.html.InputElement -> Option<T> -> Void;

/**
  The following keys all expect string values, which will be added directly to
  the DOM as classes on the fancy search input element, the suggestion list and
  item elements, and various other buttons and components.
**/
typedef FancySearchClassNames = {
  /** Default: `fs-search-input` **/
  @:optional var input : String;

  /** Default: `fs-search-input-empty` **/
  @:optional var inputEmpty : String;

  /** Default: `fs-search-input-loading` **/
  @:optional var inputLoading : String;

  /** Default: `fs-clear-input-button` **/
  @:optional var clearButton : String;

  /** Default: `fs-suggestion-container` **/
  @:optional var suggestionContainer : String;

  /** Default: `fs-suggestion-container-open` **/
  @:optional var suggestionsOpen : String;

  /** Default: `fs-suggestion-container-closed` **/
  @:optional var suggestionsClosed : String;

  /** Default: `fs-suggestion-container-empty` **/
  @:optional var suggestionsEmpty : String;

  /** Default: `fs-suggestion-list` **/
  @:optional var suggestionList : String;

  /** Default: `fs-suggestion-item` **/
  @:optional var suggestionItem : String;

  /** Default: `fs-suggestion-item-selected` **/
  @:optional var suggestionItemSelected : String;

  /** Default: `fs-suggestion-highlight` **/
  @:optional var suggestionHighlight : String;

  /** Default: `fs-suggestion-highlighted` **/
  @:optional var suggestionHighlighted : String;
};

/**
  The following actions can be triggered via keyboard shortcuts. The provided
  Array of Ints for each action defines an array of keyboard keycodes that will
  cause the associated action to trigger.
**/
typedef FancySearchKeyboardShortcuts = {
  /** Causes the suggestion list to close. Default: `[27]` (Escape key) **/
  @:optional var closeMenu : Array<Int>;

  /** Moves the selection up in the list. Default: `[38]` (Up arrow key) **/
  @:optional var selectionUp : Array<Int>;

  /** Moves the selection down in the list. Default: `[40, 9]` (Down arrow, tab) **/
  @:optional var selectionDown : Array<Int>;

  /** Chooses the currently-selected item. Default: `[13]` (Enter key) **/
  @:optional var selectionChoose : Array<Int>;
};

/**
  This is the object of options passed to the `Search` constructor.
**/
typedef FancySearchOptions<T> = {
  /** Optionally override any of the default class strings **/
  @:optional var classes : FancySearchClassNames;

  /**
    Boolean that determines whether a clear button should be shown. Default:
    `true`
  **/
  @:optional var clearBtn : Bool;

  /**
    A container DOM element for the search input. This element should be
    positioned (e.g. `absolute` or `relative`) in CSS. When using the normal
    constructor, the provided input element's parent is the default. When using
    the `Search.createFromContainer` factory, the provided container is default.
  **/
  @:optional var container : js.html.Element;

  /** Optionally override any of the default keyboard shortcuts **/
  @:optional var keys : FancySearchKeyboardShortcuts;

  /**
    Number of characters that must be typed before suggestion list is shown.
    `0` means the list will be shown any time the input has focus. The default
    value is `1`.
  **/
  @:optional var minLength : Int;

  /**
    Action to be performed when the clear button is clicked. Only relevant if
    `clearBtn` is `true`. By default, this clears the input's value and filters
    the suggestion list, given no input. This function is called on `mousedown`,
    and the provided argument is the mouse event.
  **/
  @:optional var onClearButtonClick : js.html.Event -> Void;

  /**
    Optional function to asynchronously update the suggestion list when the
    input's value changes. This function is called `oninput`, and is given the
    string value of the input. It should return a promise for a new array of
    suggestions. No default exists; this is skipped if no function is provided.
  **/
  @:optional var populateSuggestions : String -> thx.promise.Promise<Array<T>>;

  /** Optionally override any of the default suggestion options **/
  @:optional var suggestionOptions : SuggestionOptions<T>;
};

/**
  Possible positions for the literal "Search for: **text**" suggestion. `First`
  inserts it at the top of the list, and `Last` appends it at the bottom.
**/
enum LiteralPosition {
  First;
  Last;
}

/**
  Suggestion options are passed to the `Search` constructor as a child of
  `FancySearchOptions`. These options control the look and behavior of the
  dropdown suggestion list.
**/
typedef SuggestionOptions<T> = {
  /** Optionally override the default `FilterFunction` **/
  @:optional var filterFn : FilterFunction<T>;

  /** Optionally override the default `SortSuggestions` function **/
  @:optional var sortSuggestionsFn : SortSuggestions<T>;

  /** The maximum number of suggestions to be show. Default `5` **/
  @:optional var limit : Int;

  /** Whether to start with the top suggestion selected. Default: false **/
  @:optional var alwaysSelected : Bool;

  /** Optionally override the default `selectionChooseFunction` **/
  @:optional var onChooseSelection : SelectionChooseFunction<T>;

  @:dox(hide) @:optional var input : js.html.InputElement;

  @:dox(hide) @:optional var parent : js.html.Element;

  /** Whether to show the literal "Search for: ..." string. Default: `false` **/
  @:optional var showSearchLiteralItem : Bool;

  /** Position of the literal "Search for: ..." suggestion. Default: `First` **/
  @:optional var searchLiteralPosition : LiteralPosition;

  /**
    Function to convert the input's value to a literal string to follow the
    "Search for:" prefix. By default, this just returns the input's value.
  **/
  @:optional var searchLiteralValue : InputElement -> String;

  /** String preceding the literal input string. Default: `"Search for: "` **/
  @:optional var searchLiteralPrefix : String;

  /**
    This array of suggestion items can be any type. The type provided here sets
    the type for everything else. Strings would be a common choice, but anything
    you can filter and represent as a string will work.

    By default, this is an empty array.
  **/
  @:optional var suggestions : Array<T>;

  /**
    While your suggestions can by any type, we need to convert them to strings
    to render in the DOM list of dropdown suggestions. The default function
    calls `Std.string()` on the item.

    If you provide a suggestion list of simple types such as numbers or strings,
    the default is fine. For complex types, you'll want to override this.
  **/
  @:optional var suggestionToString : T -> String;
  @:optional var suggestionToElement : T -> Element;
};
