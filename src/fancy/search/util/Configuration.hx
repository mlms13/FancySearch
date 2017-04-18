package fancy.search.util;

import haxe.ds.Option;
import js.html.Element;
import thx.Lazy;

typedef Configuration<T> = {
  filterer: Filterer<T>,
  renderView: T -> js.html.Element,
  equals: T -> T -> Bool,
  clearButton: Option<Lazy<Element>>,
  minLength: Int,
  alwaysHighlight: Bool
};

enum SuggestionItem<T> {
  Suggestion(value: T); // will be rendered as a thing you can select
  Label(label: Lazy<Element>); // TODO: `Element` could be another type parameter
}

typedef Filterer<T> = Option<String> -> thx.promise.Promise<Array<SuggestionItem<T>>>;
