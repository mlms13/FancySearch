package fancy.search.config;

import haxe.ds.Option;
import js.html.Element;
import thx.Lazy;

typedef AppConfig<Sug, Filter, Value> = {
  filterer: Filterer<Sug, Filter>,
  sugEq: Sug -> Sug -> Bool,
  filterEq: Filter -> Filter -> Bool,
  allowMenu: Filter -> AllowMenu,
  alwaysHighlight: Bool,
  initFilter: Filter,
  initValue: Value,

  // called when the ChooseCurrent action is dispatched...
  // given the current highlight, current filter, and current value,
  // you tell us how to produce a new value
  getValue: Option<Sug> -> Filter -> Value -> Value
};

typedef Filterer<Sug, Filter> = Filter -> thx.promise.Promise<Array<Sug>>;

enum AllowMenu {
  Allow;
  Disallow(reason: String);
}
