package fancy;

import js.html.InputElement;

typedef FilterFunction = Array<String> -> String -> Array<String>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<thx.Tuple.Tuple2<Int, Int>>>;
typedef SelectionChooseFunction = js.html.InputElement -> String -> Void;

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