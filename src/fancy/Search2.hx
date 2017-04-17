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

class Search2<T> {
  public var store(default, null): Store<State<T>, Action<T>>;

  public function new(config: Configuration<T>) {
    var state = { config: config, input: None, menu: Closed };
    var middleware = Middleware.empty() + loadSuggestions(config);

    store = new thx.stream.Store(new Property(state), fancy.search.Reducer.reduce, middleware);
  }

  static function loadSuggestions<T>(config: Configuration<T>): Middleware<State<T>, Action<T>> {
    // TODO: inside here, we're going to have to make sure we only update the state
    // when the currently-applicable promise returns
    return function (state, action, dispatch) {
      var inputLength = thx.Options.cata(state.input, 0, fn(_.length));

      if (inputLength >= state.config.minLength) {
        switch action {
          // reducer runs first, so input value is already updated by the time we get here,
          // so we can ignore the content of ChangeValue
          case OpenMenu | ChangeValue(_): config.filterer(state.input)
            .success.fn(dispatch(PopulateSuggestions(thx.Nel.fromArray(_))))
            .failure(function (_) dispatch(FailSuggestions));
          case _: // do nothing
        }
      }
    };
  }
}
