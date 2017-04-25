package fancy.search.defaults;

import haxe.ds.Option;
import thx.Functions.fn;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.config.AppConfig;

enum StringOrSuggestion<Sug> {
  Raw(val: String);
  Suggestion(sugg: Sug);
}

typedef BaseAutocompleteOptions<Sug> = {
  sugEq: Sug -> Sug -> Bool,
  ?minLength: Int,
  ?alwaysHighlight: Bool
};

typedef SyncAutocompleteOptions<Sug> = {
  > BaseAutocompleteOptions<Sug>,
  suggestions: Array<Sug>,
  filter: Sug -> String -> Bool,
  ?limit: Int
};

typedef AsyncAutocompleteOptions<Sug> = {
  > BaseAutocompleteOptions<Sug>,
  filterer: String -> Promise<Array<Sug>>
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
  static function create<Sug>(
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

  public static function filterSync<Sug>(all: Array<Sug>, condition: Sug -> String -> Bool, limit: Option<Int>): Filterer<Sug, String> {
    return function (search: String): Promise<Array<Sug>> {
      var filtered = search.isEmpty() ? all : all.filter(condition.bind(_, search));
      return Promise.value(limit.cata(filtered, fn(filtered.slice(0, _))));
    }
  }

  public static inline function async<Sug>(opts: AsyncAutocompleteOptions<Sug>): AppConfig<Sug, String, StringOrSuggestion<Sug>> {
    return create(opts.filterer, opts.sugEq, opts.minLength, opts.alwaysHighlight);
  }

  public static inline function sync<Sug>(opts: SyncAutocompleteOptions<Sug>): AppConfig<Sug, String, StringOrSuggestion<Sug>> {
    return create(
      filterSync(opts.suggestions, opts.filter, Options.ofValue(opts.limit)),
      opts.sugEq,
      opts.minLength,
      opts.alwaysHighlight
    );
  }
}
