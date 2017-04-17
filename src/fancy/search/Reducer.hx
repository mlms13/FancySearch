package fancy.search;

import haxe.ds.Option;
using thx.Arrays;
import thx.Nel;
using thx.Options;

import fancy.search.State;
import fancy.search.util.Configuration;

class Reducer {
  public static function reduce<T>(state: State<T>, action: Action<T>): State<T> {
    return {
      // config remains unchanged, as it's always unaffected by actions
      config: state.config,

      // if we were told about a value change, update our input text
      input: switch action {
        case ChangeValue(val): thx.Strings.isEmpty(val) ? None : Some(val);
        case _: state.input;
      },

      // most of that actions affect the menu state
      menu: switch [state.menu, action] {
        // if the menu is closed and we're told to open it, try
        case [Closed, OpenMenu]: openMenu(state.config, state.input.getOrElse(""));

        // if the menu is already open or unopenable, ignore requests to open
        case [Open(_), OpenMenu] | [InputTooShort, OpenMenu]: state.menu;

        // if the menu is open and results have loaded, show them
        case [Open(_), PopulateSuggestions(None)]: Open(NoResults);
        case [Open(_), PopulateSuggestions(Some(suggestions))]: showSuggestions(state.config, suggestions);

        // if the menu is open and results have failed, show the failure state
        case [Open(_), FailSuggestions]: Open(Failed);

        // but if the menu is not open when results fail, leave it as is
        case [Closed, FailSuggestions] | [InputTooShort, FailSuggestions]: state.menu;

        // if we're told to close the menu, just do it
        case [_, CloseMenu]: Closed;

        // TODO: handle moving the highlight
        case [Open(Results(list, highlighted)), ChangeHighlight(_)]: state.menu;

        // if the menu is closed, loading, or has no results,
        // and we receive an instruction to change hightlight... ignore it
        case [Closed, ChangeHighlight(_)] |
             [InputTooShort, ChangeHighlight(_)] |
             [Open(Loading), ChangeHighlight(_)] |
             [Open(NoResults), ChangeHighlight(_)] |
             [Open(Failed), ChangeHighlight(_)]: state.menu;

        // ignore requests to populate suggestions if the menu isn't open
        case [Closed, PopulateSuggestions(_)] |
             [InputTooShort, PopulateSuggestions(_)]: state.menu;

        // ignore value changes when the menu is closed
        case [Closed, ChangeValue(_)]: Closed;

        // any other time the value changes, switch the menu to a loading state
        // the middleware will handle firing the next action
        case [_, ChangeValue(_)]: Open(Loading);

        // TODO: do we care about choosing a suggestion, or is that all middleware?
        case [_, Choose(_)]: state.menu;
      }
    };
  }

  // show the correct menu state, given a request to open it
  static function openMenu<T>(config: Configuration<T>, inputValue: String): MenuState<T> {
    return inputValue.length < config.minLength ? InputTooShort : Open(Loading);
  }

  static function firstT<T>(suggs: Nel<SuggestionItem<T>>): Option<T> {
    return suggs.toArray().findMap(function (s) {
      return switch s {
        case Suggestion(v): Some(v);
      case Label(_): None;
      };
    });
  }

  static function showSuggestions<T>(config: Configuration<T>, suggestions: Nel<SuggestionItem<T>>): MenuState<T> {
    // we can't just git the head() of the nel because not all items in the list
    // are true suggestions, but at least we have the power of `firstT`
    return Open(Results(suggestions, config.alwaysHighlight ? firstT(suggestions) : None));
  }
}
