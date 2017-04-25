package fancy.search.defaults;

import haxe.ds.Option;
using thx.Options;
import thx.promise.Promise;
import fancy.search.config.AppConfig;

enum StringOrSuggestion<Sug> {
  Raw(val: String);
  Suggestion(sugg: Sug);
}

/**
 *  This class provides static functions to help you create app and renderer
 *  configurations for the most common FancySearch: an autocomplete search.
 *
 *  The type of suggestions are still variable, but the filter function is
 *  always called with a string, and when the ui triggers a `Choose` action,
 *  the provided value will either be the `Selection` if one existed, or the
 *  `Raw` input string if nothing was highlighted.
 */
class AutocompleteDefaults {
  public static function create<Sug>(
    filterer: String -> Promise<Array<Sug>>,
    sugEq: Sug -> Sug -> Bool,
    ?minLength = 0,
    ?alwaysHighlight = true
  ): AppConfig<Sug, String, StringOrSuggestion<Sug>> {
    return {
      filterer: filterer,
      sugEq: sugEq,
      allowMenu: function (filter: String) {
        return filter.length >= minLength ? Allow : Disallow("Input too short");
      },
      alwaysHighlight: alwaysHighlight,
      initValue: Raw(""),
      initFilter: "",
      getValue: function (highlight: Option<Sug>, filter: String, curr: StringOrSuggestion<Sug>) {
        return highlight.map(Suggestion).getOrElse(Raw(filter));
      }
    };
  }
}
