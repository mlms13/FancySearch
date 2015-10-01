package fancy;

typedef FancySearchOptions = {
  ?classes : FancySearchClassNames,
  ?clearBtn : Bool,
  ?container : js.html.Element,
  ?keys : FancySearchKeyboardShortcuts,
  ?minLength : Int,
  ?onClearButtonClick : js.html.Event -> Void,
  ?suggestionOptions : SuggestionOptions
};
