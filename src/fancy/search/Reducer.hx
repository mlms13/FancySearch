package fancy.search;

import haxe.ds.Option;
using thx.Arrays;
import thx.Nel;
using thx.Options;

import fancy.search.Action;
import fancy.search.State;
import fancy.search.util.Configuration;

class Reducer {
  public static function reduce<T, TValue>(state: State<T, TValue>, action: Action<T, TValue>): State<T, TValue> {
    return {
      // config remains unchanged, as it's always unaffected by actions
      config: state.config,

      // if we were told about a value change, update our input text
      input: switch action {
        case ChangeValue(val): val;
        case Choose(suggOpt, val): state.config.choose(suggOpt, val);
        case _: state.input;
      },

      // most of that actions affect the menu state
      menu: switch [state.menu, action] {
        // if the menu is closed and we're told to open it, try
        case [Closed(Inactive), OpenMenu]: openMenu(state.config, state.input);

        // if the menu is already open or unopenable, ignore requests to open
        case [Open(_), OpenMenu] | [Closed(FailedCondition(_)), OpenMenu]: state.menu;

        // if the menu is open and results have loaded, show them
        case [Open(_), PopulateSuggestions(None, highlighted)]: Open(NoResults, None);
        case [Open(_), PopulateSuggestions(Some(suggestions), highlight)]: showSuggestions(state.config, suggestions, highlight);

        // if the menu is open and results have failed, show the failure state
        case [Open(_, highlighted), FailSuggestions]: Open(Failed, highlighted);

        // but if the menu is not open when results fail, leave it as is
        case [Closed(_), FailSuggestions]: state.menu;

        // if we're told to close the menu, just do it
        case [_, CloseMenu]: Closed(Inactive);

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
        case [Closed(_), ChangeHighlight(_)] |
             [Open(Loading, _), ChangeHighlight(_)] |
             [Open(NoResults, _), ChangeHighlight(_)] |
             [Open(Failed, _), ChangeHighlight(_)]: state.menu;

        // ignore requests to populate suggestions if the menu isn't open
        case [Closed(_), PopulateSuggestions(_)]: state.menu;


        // any other time the value changes, switch the menu to a loading state
        // the middleware will handle firing the next action
        case [Open(_, highlight), ChangeValue(_)]: Open(Loading, highlight);

        // open a closed menu when the value changes
        case [Closed(_), ChangeValue(_)]: Open(Loading, None);

        // mostly input cares about this, but we close the menu
        case [_, Choose(_)]: Closed(Inactive);
      }
    };
  }

  // show the correct menu state, given a request to open it
  static function openMenu<T, TValue>(config: Configuration<T, TValue>, inputValue: Option<TValue>): MenuState<T> {
    return switch config.hideMenuCondition(inputValue) {
      case None: Open(Loading, None);
      case Some(reason): Closed(FailedCondition(reason));
    };
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

  static function showSuggestions<T, TValue>(config: Configuration<T, TValue>, suggestions: Nel<SuggestionItem<T>>, highlight: Option<T>): MenuState<T> {
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

  static function moveHighlight<T, TValue>(config: Configuration<T, TValue>, suggestions: Nel<SuggestionItem<T>>, highlighted: Option<T>, dir: Direction): MenuState<T> {
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
