package fancy.search;

import haxe.ds.Option;

import fancy.search.util.Configuration;

typedef State<TSugg, TInput> = {
  config: Configuration<TSugg, TInput>,
  input: Option<TInput>,
  menu: MenuState<TSugg>
};

enum MenuState<TSugg> {
  Closed(reason: ClosedReason);
  Open(dropdown: DropdownState<TSugg>, highlighted: Option<TSugg>);
}

enum ClosedReason {
  Inactive;
  FailedCondition(reason: String);
}

enum DropdownState<TSugg> {
  Loading;
  NoResults;
  Failed;
  Results(suggestions: thx.Nel<SuggestionItem<TSugg>>);
}
