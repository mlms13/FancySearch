package fancy.search;

import haxe.ds.Option;
import thx.Nel;

enum Action<Sug, Filter, Value> {
  OpenMenu;
  CloseMenu;
  SetFilter(filter: Filter);
  PopulateSuggestions(suggestions: Option<Nel<Sug>>, highlight: Option<Sug>);
  FailSuggestions;
  ChangeHighlight(change: HighlightChangeType<Sug>);
  ChooseCurrent; // given the current Filter/Highlight, try to set a value
  SetValue(val: Value);
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
