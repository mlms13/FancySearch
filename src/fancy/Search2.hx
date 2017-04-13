package fancy;

import haxe.ds.Option;
using thx.Functions;
import thx.stream.Store;
import thx.stream.Property;
import thx.stream.Reducer.Middleware;

import fancy.search.State;
import fancy.search.Action;
import fancy.search.util.Configuration;

class Search2<T> {
  public var store(default, null): Store<State<T>, Action<T>>;

  public function new(config: Configuration<T>) {
    var state = { config: config, input: None, menu: Closed };
    var middleware = Middleware.empty() + loadSuggestions(config);

    store = new thx.stream.Store(new Property(state), fancy.search.Reducer.reduce, middleware);
  }

  static function loadSuggestions<T>(config: Configuration<T>): Middleware<State<T>, Action<T>> {
    return function (state, action, dispatch) {

      // TODO: only if input length is long enough
      // TODO: something like this should also happen on ChangeValue
      switch action {
        case OpenMenu: config.filterer(state.input)
          .success.fn(dispatch(PopulateSuggestions(thx.Nel.fromArray(_))))
          .failure.fn(trace(_)); // TODO: failed state
        case _: // do nothing
      }
    };
  }
}
