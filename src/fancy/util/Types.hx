package fancy.util;

import js.html.InputElement;

typedef FilterFunction = Array<String> -> String -> Array<String>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<thx.Tuple.Tuple2<Int, Int>>>;
typedef SelectionChooseFunction = js.html.InputElement -> String -> Void;

typedef FancySearchClassNames = {
  ?input : String,
  ?inputEmpty : String,
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

typedef FancySearchOptions = {
  ?classes : FancySearchClassNames,
  ?clearBtn : Bool,
  ?container : js.html.Element,
  ?keys : FancySearchKeyboardShortcuts,
  ?minLength : Int,
  ?onClearButtonClick : js.html.Event -> Void,
  ?suggestionOptions : SuggestionOptions
};

enum LiteralPosition {
  First;
  Last;
}

typedef SuggestionOptions = {
  ?filterFn : FilterFunction,
  ?highlightLettersFn : HighlightLetters,
  ?limit : Int,
  ?onChooseSelection : SelectionChooseFunction,
  ?input : js.html.InputElement,
  ?parent : js.html.Element,
  ?showSearchLiteralItem : Bool,
  ?searchLiteralPosition : LiteralPosition,
  ?searchLiteralValue : InputElement -> String,
  ?searchLiteralPrefix : String,
  ?suggestions : Array<String>,
};
