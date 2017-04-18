package fancy.search.util;

import haxe.ds.Option;
import js.html.Element;
import thx.Lazy;

typedef Configuration<TSugg, TValue> = {
  filterer: Filterer<TSugg, TValue>,
  choose: Option<TValue> -> Option<TSugg> -> Option<TValue>,
  renderView: TSugg -> js.html.Element,
  equals: TSugg -> TSugg -> Bool,
  clearButton: Option<Lazy<Element>>,
  hideMenuCondition: Option<TValue> -> Option<String>, // TODO: add documentation
  alwaysHighlight: Bool
};

enum SuggestionItem<T> {
  Suggestion(value: T); // will be rendered as a thing you can select
  Label(label: Lazy<Element>); // TODO: `Element` could be another type parameter
}

typedef Filterer<TSugg, TValue> = Option<TValue> -> thx.promise.Promise<Array<SuggestionItem<TSugg>>>;
