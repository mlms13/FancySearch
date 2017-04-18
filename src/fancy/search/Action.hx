package fancy.search;

import haxe.ds.Option;
import thx.Nel;
import fancy.search.util.Configuration;

enum Action<TSugg, TValue> {
  ChangeValue(newValue: Option<TValue>);
  OpenMenu;
  CloseMenu;
  PopulateSuggestions(suggestions: Option<Nel<SuggestionItem<TSugg>>>, highlight: Option<TSugg>);
  FailSuggestions;
  ChangeHighlight(change: HighlightChangeType<TSugg>);
  Choose(suggestion: Option<TSugg>, val: Option<TValue>);
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
