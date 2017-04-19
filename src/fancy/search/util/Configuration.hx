package fancy.search.util;

import haxe.ds.Option;
import js.html.Element;
import thx.Lazy;

typedef Configuration<TSugg, TInput> = {
  filterer: Filterer<TSugg, TInput>,
  equals: TSugg -> TSugg -> Bool,
  hideMenuCondition: Option<TInput> -> Option<String>, // TODO: add documentation
  alwaysHighlight: Bool
};

enum SuggestionItem<T> {
  Suggestion(value: T); // will be rendered as a thing you can select
  Label(label: Lazy<Element>); // TODO: `Element` could be another type parameter
}

typedef Filterer<TSugg, TInput> = Option<TInput> -> thx.promise.Promise<Array<SuggestionItem<TSugg>>>;
