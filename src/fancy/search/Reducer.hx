package fancy.search;

using thx.Options;

import fancy.search.State;
import fancy.search.util.Configuration;

class Reducer {
  public static function reduce<T>(state: State<T>, action: Action<T>): State<T> {
    trace("reducer with action", action);
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

        // if we're told to close the menu, just do it
        case [_, CloseMenu]: Closed;

        // TODO: handle moving the highlight
        case [Open(Results(list, highlighted)), ChangeHighlight(_)]: state.menu;

        // if the menu is closed, loading, or has no results,
        // and we receive an instruction to change hightlight... ignore it
        case [Closed, ChangeHighlight(_)] |
             [InputTooShort, ChangeHighlight(_)] |
             [Open(Loading), ChangeHighlight(_)] |
             [Open(NoResults), ChangeHighlight(_)]: state.menu;

        // ignore requests to populate suggestions if the menu isn't open
        case [Closed, PopulateSuggestions(_)] |
             [InputTooShort, PopulateSuggestions(_)]: state.menu;

        // we don't care about changing values here... middleware re-filters
        // and the `input` part of state cares, but the menu doesn't
        case [_, ChangeValue(_)]: state.menu;

        // TODO: do we care about choosing a suggestion, or is that all middleware?
        case [_, Choose(_)]: state.menu;
      }
    };
  }

  // show the correct menu state, given a request to open it
  static function openMenu<T>(config: Configuration<T>, inputValue: String): MenuState<T> {
    return inputValue.length < config.minLength ? InputTooShort : Open(Loading);
  }

  static function showSuggestions<T>(config: Configuration<T>, suggestions: thx.Nel<SuggestionItem<T>>): MenuState<T> {
    // TODO `Some(suggestions.head())` doesn't work because we need a true T, not a SuggestionItem
    return Open(Results(suggestions, config.alwaysHighlight ? None : None));
  }
}
