package fancy.search;

import haxe.ds.Option;

import fancy.search.util.Configuration;

typedef State<TSugg, TInput> = {
  config: Configuration<TSugg, TInput>,
  input: Option<TInput>,
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
