package fancy.search;

import haxe.ds.Option;
import thx.Nel;
import fancy.search.util.Configuration;

enum Action<T> {
  ChangeValue(newValue: String);
  OpenMenu;
  CloseMenu;
  PopulateSuggestions(suggestions: Option<Nel<SuggestionItem<T>>>, highlight: Option<T>);
  FailSuggestions;
  ChangeHighlight(change: HighlightChangeType<T>);
  Choose(suggestion: T);
}

enum HighlightChangeType<T> {
  Unhighlight;
  Specific(suggestion: T);
  Move(direction: Direction);
}

enum Direction {
  Up;
  Down;
}
