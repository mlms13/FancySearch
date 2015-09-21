package fancy;

typedef FilterFunction = Array<String> -> String -> Array<String>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<thx.Tuple.Tuple2<Int, Int>>>;
typedef SelectionChooseFunction = js.html.InputElement -> String -> Void;

typedef SuggestionOptions = {
  classes : SuggestionClassNames,
  ?filterFn : FilterFunction,
  ?highlightLettersFn : HighlightLetters,
  limit : Int,
  onChooseSelection : SelectionChooseFunction,
  input : js.html.InputElement,
  parent : js.html.Element,
  ?suggestions : Array<String>,
};
