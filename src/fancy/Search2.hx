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

class Search2<TSugg, TValue> {
  public var store(default, null): Store<State<TSugg, TValue>, Action<TSugg, TValue>>;

  public function new(config: Configuration<TSugg, TValue>) {
    var state = { config: config, input: None, menu: Closed(Inactive) };
    var middleware = Middleware.empty() + loadSuggestions(config);

    store = new thx.stream.Store(new Property(state), fancy.search.Reducer.reduce, middleware);
  }

  static function loadSuggestions<TSugg, TValue>(config: Configuration<TSugg, TValue>): Middleware<State<TSugg, TValue>, Action<TSugg, TValue>> {
    // TODO: inside here, we're going to have to make sure we only update the state
    // when the currently-applicable promise returns
    return function (state, action, dispatch) {
      switch state.config.hideMenuCondition(state.input) {
        case None:
          switch [state.menu, action] {
            // reducer runs first, so input value is already updated by the time we get here,
            // so we can ignore ChangeValue's content. also menu will definitely be Open
            case [Open(_, h), OpenMenu] | [Open(_, h), ChangeValue(_)]:
              config.filterer(state.input)
                .success.fn(dispatch(PopulateSuggestions(thx.Nel.fromArray(_), h)))
                .failure(function (_) dispatch(FailSuggestions));
            case _: // do nothing
          }
        case _: // more do nothing
      }
    };
  }
}
