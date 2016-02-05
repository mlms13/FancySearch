package fancy.search.util;

import haxe.ds.Option;
import js.html.InputElement;

typedef FilterFunction<T> = (T -> String) -> Array<T> -> String -> Array<T>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<thx.Tuple.Tuple2<Int, Int>>>;
typedef SelectionChooseFunction<T> = (T -> String) -> js.html.InputElement -> Option<T> -> Void;

typedef FancySearchClassNames = {
  ?input : String,
  ?inputEmpty : String,
  ?inputLoading : String,
  ?clearButton : String,
  ?suggestionContainer : String,
  ?suggestionsOpen : String,
  ?suggestionsClosed : String,
  ?suggestionsEmpty : String,
  ?suggestionList : String,
  ?suggestionItem : String,
  ?suggestionItemSelected : String
};

typedef FancySearchKeyboardShortcuts = {
  ?closeMenu : Array<Int>,
  ?selectionUp : Array<Int>,
  ?selectionDown : Array<Int>,
  ?selectionChoose : Array<Int>
};

typedef FancySearchOptions<T> = {
  ?classes : FancySearchClassNames,
  ?clearBtn : Bool,
  ?container : js.html.Element,
  ?keys : FancySearchKeyboardShortcuts,
  ?minLength : Int,
  ?onClearButtonClick : js.html.Event -> Void,
  ?suggestionOptions : SuggestionOptions<T>,
  ?populateSuggestions : String -> thx.promise.Promise<Array<T>>,
};

enum LiteralPosition {
  First;
  Last;
}

typedef SuggestionOptions<T> = {
  ?filterFn : FilterFunction<T>,
  ?highlightLettersFn : HighlightLetters,
  ?limit : Int,
  ?onChooseSelection : SelectionChooseFunction<T>,
  ?input : js.html.InputElement,
  ?parent : js.html.Element,
  ?showSearchLiteralItem : Bool,
  ?searchLiteralPosition : LiteralPosition,
  ?searchLiteralValue : InputElement -> String,
  ?searchLiteralPrefix : String,
  ?suggestions : Array<T>,
  ?suggestionToString : T -> String,
};
