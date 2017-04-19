package fancy.search;

import haxe.ds.Option;

import fancy.search.util.Configuration;

typedef State<Sug, Filter, Value> = {
  config: Configuration<Sug, Filter, Value>,
  filter: Filter,
  value: Value,
  menu: MenuState<Sug>
};

enum MenuState<Sug> {
  Closed(reason: ClosedReason);
  Open(dropdown: DropdownState<Sug>, highlighted: Option<Sug>);
}

enum ClosedReason {
  Inactive;
  FailedCondition(reason: String);
}

enum DropdownState<Sug> {
  Loading;
  NoResults;
  Failed;
  Results(suggestions: thx.Nel<Sug>);
}
