package fancy;

typedef FilterFunction = Array<String> -> String -> Array<String>;
typedef HighlightLetters = Array<String> -> String -> Array<Array<thx.Tuple.Tuple2<Int, Int>>>;
typedef SelectionChooseFunction = String -> Void;

typedef SuggestionOptions = {
  classes : SuggestionClassNames,
  ?filterFn : FilterFunction,
  ?highlightLettersFn : HighlightLetters,
  limit : Int,
  onChooseSelection : SelectionChooseFunction,
  parent : js.html.Element,
  ?suggestions : Array<String>,
};
