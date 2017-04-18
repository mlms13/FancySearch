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

        // only unhighlight when not in `alwaysHighlight` mode
        case [Open(Results(list), h), ChangeHighlight(Unhighlight)]:
          Open(Results(list), state.config.alwaysHighlight ? h : None);

        // highlight a specific result
        case [Open(Results(list), _), ChangeHighlight(Specific(v))]:
          Open(Results(list), Some(v));

        // move the highlight up or down
        case [Open(Results(list), highlighted), ChangeHighlight(Move(dir))]:
          moveHighlight(state.config, list, highlighted, dir);

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

  static function hasT<T>(suggs: thx.ReadonlyArray<SuggestionItem<T>>, t: T, eq: T -> T -> Bool): Bool {
    return suggs.contains(t, function (curr: SuggestionItem<T>, t: T) {
      return switch curr {
        case Label(_): false;
        case Suggestion(v): eq(t, v);
      };
    });
  }

  static function showSuggestions<T>(config: Configuration<T>, suggestions: Nel<SuggestionItem<T>>, highlight: Option<T>): MenuState<T> {
    var suggArray = suggestions.toArray();
    // if PopulateSuggestions told us to highlight a specific T, make sure that
    // T exists in the list, then highlight it. Otherwise, if config tells us to
    // always highlight, pick the first
    var h: Option<T> = highlight.flatMap(function (v) {
      return hasT(suggArray, v, config.equals) ? Some(v) : None;
    }).cataf(
      function () {
        // PopulateSuggestions didn't give us an element to highlight
        return config.alwaysHighlight ? firstT(suggArray) : None;
      },
      Some
    );
    return Open(Results(suggestions), h);
  }

  static function moveHighlight<T>(config: Configuration<T>, suggestions: Nel<SuggestionItem<T>>, highlighted: Option<T>, dir: Direction): MenuState<T> {
    // make sure we only move through suggestion Ts, not labels
    // wrap around when we Up from the first or Down from the last
    var ts = suggestions.toArray().filterMap(function (item) {
      return switch item {
        case Label(_): None;
        case Suggestion(t): Some(t);
      };
    });

    var indexOfHighlighted = highlighted.flatMap(function (h: T) {
      var index = ts.findIndex(config.equals.bind(h));
      return index == -1 ? None : Some(index);
    });

    var newHighlight: Option<T> = switch [dir, indexOfHighlighted] {
      case [Up, None]: ts.lastOption();
      case [Up, Some(i)]: i - 1 < 0 ? ts.lastOption() : ts.getOption(i - 1);
      case [Down, None]: ts.firstOption();
      case [Down, Some(i)]: i + 1 >= ts.length ? ts.firstOption() : ts.getOption(i + 1);
    }

    return Open(Results(suggestions), newHighlight);
  }
}
