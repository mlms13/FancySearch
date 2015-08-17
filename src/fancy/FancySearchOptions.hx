package fancy;

typedef FancySearchOptions = {
  ?classes : FancySearchClassNames,
  ?clearBtn : Bool,
  ?container : js.html.Element,
  ?filter : SuggestionOptions.FilterFunction,
  ?highlightLetters : SuggestionOptions.HighlightLetters,
  ?keys : FancySearchKeyboardShortcuts,
  ?limit : Int,
  ?minLength : Int,
  ?onChooseSelection : SuggestionOptions.SelectionChooseFunction,
  ?onClearButtonClick : js.html.Event -> Void,
  ?suggestions : Array<String>,
};
