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

enum Value<TSugg, TInput> {
  Suggestion(sugg: TSugg);
  Raw(raw: Option<TInput>);
}

class Search<TSugg, TInput> {
  public var store(default, null): Store<State<TSugg, TInput>, Action<TSugg, TInput>>;
  public var values(default, null): thx.stream.Stream<Value<TSugg, TInput>>;

  public function new(config: Configuration<TSugg, TInput>) {
    var state = { config: config, input: None, menu: Closed(Inactive) };
    var middleware = Middleware.empty() + loadSuggestions(config);

    store = new thx.stream.Store(new Property(state), fancy.search.Reducer.reduce, middleware);
    // TODO: values
  }

  static function loadSuggestions<TSugg, TInput>(config: Configuration<TSugg, TInput>): Middleware<State<TSugg, TInput>, Action<TSugg, TInput>> {
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
