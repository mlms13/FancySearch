package fancy.search;

import haxe.ds.Option;

import fancy.search.util.Configuration;

typedef State<T> = {
  config: Configuration<T>,
  input: Option<String>,
  menu: MenuState<T>
};

enum MenuState<T> {
  Closed;
  InputTooShort; // it's up to the renderer to decide if this appears closed
  Open(dropdown: DropdownState<T>);
}

enum DropdownState<T> {
  Loading;
  NoResults;
  Results(suggestions: thx.Nel<SuggestionItem<T>>, highlighted: Option<T>);
}
