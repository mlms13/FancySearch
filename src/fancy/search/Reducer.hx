package fancy.search;

import haxe.ds.Option;
using thx.Arrays;
import thx.Nel;
using thx.Options;

import fancy.search.Action;
import fancy.search.State;
import fancy.search.util.Configuration;

class Reducer {
  public static function reduce<Sug, Filter, Value>(state: State<Sug, Filter, Value>, action: Action<Sug, Filter, Value>): State<Sug, Filter, Value> {
    return {
      // config remains unchanged, as it's always unaffected by actions
      config: state.config,

      // if we were told about a filter change, update the filter
      filter: switch action {
        case SetFilter(filter): filter;
        case _: state.filter;
      },

      // value changes when it's set directly, or when we're instructed
      // to set the value based on the current state
      value: switch action {
        case SetValue(v): v;
        case ChooseCurrent: state.config.getValue(getHighlight(state.menu), state.filter, state.value);
        case _: state.value;
      },

      // most of that actions affect the menu state
      menu: switch [state.menu, action] {
        // if the menu is closed and we're told to open it, try
        case [Closed(Inactive), OpenMenu]: openMenu(state.config, state.filter);

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


        // any other time the filter changes, switch the menu to a loading state
        // the middleware will handle firing the next action
        case [Open(_, highlight), SetFilter(_)]: Open(Loading, highlight);

        // open a closed menu when the filter changes
        case [Closed(_), SetFilter(_)]: Open(Loading, None);

        // menu closes when a value is chosen
        case [_, ChooseCurrent] | [_, SetValue(_)]: Closed(Inactive);
      }
    };
  }

  // show the correct menu state, given a request to open it
  static function openMenu<Sug, Filter, Value>(config: Configuration<Sug, Filter, Value>, filter: Filter): MenuState<Sug> {
    return switch config.allowMenu(filter) {
      case Allow: Open(Loading, None);
      case Disallow(reason): Closed(FailedCondition(reason));
    };
  }

  static function getHighlight<Sug>(menu: MenuState<Sug>): Option<Sug> {
    return switch menu {
      case Open(_, h): h;
      case Closed(_): None;
    }
  }

  static function showSuggestions<Sug, A, B>(config: Configuration<Sug, A, B>, suggestions: Nel<Sug>, highlight: Option<Sug>): MenuState<Sug> {
    // if PopulateSuggestions told us to highlight a specific Sug, make sure
    // that Sug exists in the list, then highlight it. Otherwise, if config
    // tells us to always highlight, pick the first
    var h: Option<Sug> = highlight.flatMap(function (s) {
      return suggestions.toArray().contains(s, config.sugEq) ? Some(s) : None;
    })
    .orElse(config.alwaysHighlight ? Some(suggestions.head()) : None);

    return Open(Results(suggestions), h);
  }

  static function moveHighlight<Sug, A, B>(config: Configuration<Sug, A, B>, suggestions: Nel<Sug>, highlighted: Option<Sug>, dir: Direction): MenuState<Sug> {
    var suggArray = suggestions.toArray();
    var indexOfHighlighted = highlighted.flatMap(function (h) {
      var index = suggArray.findIndex(config.sugEq.bind(h));
      return index == -1 ? None : Some(index);
    });

    var newHighlight: Option<Sug> = switch [dir, indexOfHighlighted] {
      case [Up, None]: suggArray.lastOption();
      case [Up, Some(i)]: i - 1 < 0 ? suggArray.lastOption() : suggArray.getOption(i - 1);
      case [Down, None]: suggArray.firstOption();
      case [Down, Some(i)]: i + 1 >= suggArray.length ? suggArray.firstOption() : suggArray.getOption(i + 1);
    }

    return Open(Results(suggestions), newHighlight);
  }
}
