package fancy.search;

import haxe.ds.Option;
using thx.Arrays;
import thx.Nel;
using thx.Options;

import fancy.search.Action;
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
        case [Open(_), PopulateSuggestions(None, highlighted)]: Open(NoResults, highlighted);
        case [Open(_), PopulateSuggestions(Some(suggestions), highlight)]: showSuggestions(state.config, suggestions, highlight);

        // if the menu is open and results have failed, show the failure state
        case [Open(_, highlighted), FailSuggestions]: Open(Failed, highlighted);

        // but if the menu is not open when results fail, leave it as is
        case [Closed, FailSuggestions] | [InputTooShort, FailSuggestions]: state.menu;

        // if we're told to close the menu, just do it
        case [_, CloseMenu]: Closed;

        // handle highlight changes
        case [Open(Results(list), _), ChangeHighlight(Unhighlight)]: Open(Results(list), None);
        case [Open(Results(list), _), ChangeHighlight(Specific(v))]: Open(Results(list), Some(v));
        case [Open(Results(list), highlighted), ChangeHighlight(Move(dir))]: moveHighlight(list, highlighted, dir);

        // if the menu is closed, loading, or has no results,
        // and we receive an instruction to change hightlight... ignore it
        case [Closed, ChangeHighlight(_)] |
             [InputTooShort, ChangeHighlight(_)] |
             [Open(Loading, _), ChangeHighlight(_)] |
             [Open(NoResults, _), ChangeHighlight(_)] |
             [Open(Failed, _), ChangeHighlight(_)]: state.menu;

        // ignore requests to populate suggestions if the menu isn't open
        case [Closed, PopulateSuggestions(_)] |
             [InputTooShort, PopulateSuggestions(_)]: state.menu;

        // ignore value changes when the menu is closed
        case [Closed, ChangeValue(_)] | [InputTooShort, ChangeValue(_)]: state.menu;

        // any other time the value changes, switch the menu to a loading state
        // the middleware will handle firing the next action
        case [Open(_, highlight), ChangeValue(_)]: Open(Loading, highlight);

        // TODO: do we care about choosing a suggestion, or is that all middleware?
        case [_, Choose(_)]: state.menu;
      }
    };
  }

  // show the correct menu state, given a request to open it
  static function openMenu<T>(config: Configuration<T>, inputValue: String): MenuState<T> {
    return inputValue.length < config.minLength ? InputTooShort : Open(Loading, None);
  }

  static function firstT<T>(suggs: thx.ReadonlyArray<SuggestionItem<T>>): Option<T> {
    return suggs.toArray().findMap(function (s) {
      return switch s {
        case Suggestion(v): Some(v);
      case Label(_): None;
      };
    });
  }

  static function hasT<T>(toString: T -> String, suggs: thx.ReadonlyArray<SuggestionItem<T>>, t: T): Bool {
    return suggs.contains(toString(t), function (curr: SuggestionItem<T>, compare: String): Bool {
      return switch curr {
        case Label(_): false;
        case Suggestion(v): toString(v) == compare;
      };
    });
  }

  static function showSuggestions<T>(config: Configuration<T>, suggestions: Nel<SuggestionItem<T>>, highlight: Option<T>): MenuState<T> {
    var suggArray = suggestions.toArray();
    // if PopulateSuggestions told us to highlight a specific T, make sure that
    // T exists in the list, then highlight it. Otherwise, if config tells us to
    // always highlight, pick the first
    var h: Option<T> = highlight.flatMap(function (v) {
      return hasT(config.renderString, suggArray, v) ? Some(v) : None;
    }).cataf(
      function () {
        // PopulateSuggestions didn't give us an element to highlight
        return config.alwaysHighlight ? firstT(suggArray) : None;
      },
      Some
    );
    return Open(Results(suggestions), h);
  }

  static function moveHighlight<T>(suggestions: Nel<SuggestionItem<T>>, highlighted: Option<T>, dir: Direction): MenuState<T> {
    // TODO: make sure we only move through suggestion Ts, not labels
    // wrap around when we Up from the first or Down from the last
    return Open(Results(suggestions), highlighted);
  }
}
