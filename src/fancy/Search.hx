package fancy;

import haxe.ds.Option;
using thx.Functions;
import thx.Functions.fn;
import thx.stream.Store;
import thx.stream.Property;
import thx.stream.Reducer.Middleware;

import fancy.search.State;
import fancy.search.Action;
import fancy.search.util.Configuration;

class Search<Sug, Filter, Value> {
  public var store(default, null): Store<State<Sug, Filter, Value>, Action<Sug, Filter, Value>>;
  public var values(default, null): thx.stream.Stream<Value>;

  public function new(config: Configuration<Sug, Filter, Value>) {
    var state: State<Sug, Filter, Value> = {
      config: config,
      filter: config.initFilter,
      value: config.initValue,
      menu: Closed(Inactive)
    };
    var middleware = Middleware.empty() + loadSuggestions(config);

    store = new thx.stream.Store(new Property(state), fancy.search.Reducer.reduce, middleware);
    values = store.stream().map.fn(_.value).distinct();
  }

  static function loadSuggestions<Sug, Filter, Value>(config: Configuration<Sug, Filter, Value>): Middleware<State<Sug, Filter, Value>, Action<Sug, Filter, Value>> {
    // TODO: inside here, we're going to have to make sure we only update the state
    // when the currently-applicable promise returns
    return function (state, action, dispatch) {
      switch [state.config.allowMenu(state.filter), state.menu, action] {
        // reducer runs first, so filter value is already updated by the time we get here,
        // so we can ignore ChangeValue's content. also menu will definitely be Open
        case [Allow, Open(_, h), OpenMenu] | [Allow, Open(_, h), SetFilter(_)]:
          config.filterer(state.filter)
            .success.fn(dispatch(PopulateSuggestions(thx.Nel.fromArray(_), h)))
            .failure(function (_) dispatch(FailSuggestions));
        case _: // do nothing
      }
    };
  }
}
