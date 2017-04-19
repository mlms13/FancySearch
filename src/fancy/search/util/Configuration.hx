package fancy.search.util;

import haxe.ds.Option;
import js.html.Element;
import thx.Lazy;

typedef Configuration<Sug, Filter, Value> = {
  filterer: Filterer<Sug, Filter>,
  sugEq: Sug -> Sug -> Bool,
  // sugEq: Sug -> Sug -> Bool,
  allowMenu: Filter -> AllowMenu,
  alwaysHighlight: Bool,
  initFilter: Filter,
  initValue: Value,
  // getValue: Option<Filter> -> Option<Sug> -> Value
};

typedef Filterer<Sug, Filter> = Filter -> thx.promise.Promise<Array<Sug>>;

enum AllowMenu {
  Allow;
  Disallow(reason: String);
}
