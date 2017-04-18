package fancy.search;

import haxe.ds.Option;

import fancy.search.util.Configuration;

typedef State<TSugg, TValue> = {
  config: Configuration<TSugg, TValue>,
  input: Option<TValue>,
  menu: MenuState<TSugg>
};

enum MenuState<T> {
  Closed(reason: ClosedReason);
  Open(dropdown: DropdownState<T>, highlighted: Option<T>);
}

enum ClosedReason {
  Inactive;
  FailedCondition(reason: String);
}

enum DropdownState<T> {
  Loading;
  NoResults;
  Failed;
  Results(suggestions: thx.Nel<SuggestionItem<T>>);
}
