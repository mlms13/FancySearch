package fancy.search.defaults;

import haxe.ds.Option;
import thx.Functions.fn;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.config.AppConfig;

enum StringOrValue<Val> {
  Raw(val: String, prev: Option<Val>);
  Value(val: Val);
}

typedef BaseAutocompleteOptions<Sug, Val> = {
  sugEq: Sug -> Sug -> Bool,
  ?minLength: Int,
  ?alwaysHighlight: Bool,
  ?initValue: Val,
  ?initFilter: String
};

typedef SyncAutocompleteOptions<Sug, Val> = {
  > BaseAutocompleteOptions<Sug, Val>,
  suggestions: Array<Sug>,
  filter: Sug -> String -> Bool,
  ?limit: Int
};

typedef AsyncAutocompleteOptions<Sug, Val> = {
  > BaseAutocompleteOptions<Sug, Val>,
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
  static function create<Sug, Val>(
    filterer: String -> Promise<Array<Sug>>,
    sugEq: Sug -> Sug -> Bool,
    toValue: Sug -> Val,
    initValue: Option<Val>,
    initFilter = "",
    minLength = 0,
    alwaysHighlight = true
  ): AppConfig<Sug, String, StringOrValue<Val>> {
    return {
      filterer: filterer,
      sugEq: sugEq,
      filterEq: thx.Strings.order.equal,
      allowMenu: function (filter: String) {
        return filter.length >= minLength ? Allow : Disallow("Input too short");
      },
      alwaysHighlight: alwaysHighlight,
      initValue: initValue.cata(Raw("", None), Value),
      initFilter: initFilter,
      getValue: function (highlight: Option<Sug>, filter: String, curr: StringOrValue<Val>): StringOrValue<Val> {
        return highlight.map(toValue).cata(Raw(filter, getValue(curr)), Value);
      }
    };
  }

  static function getValue<Val>(x: StringOrValue<Val>): Option<Val> {
    return switch x {
      case Value(val): Some(val);
      case Raw(_, val): val;
    };
  }

  public static function filterSync<Sug>(all: Array<Sug>, condition: Sug -> String -> Bool, limit: Option<Int>): Filterer<Sug, String> {
    return function (search: String): Promise<Array<Sug>> {
      var filtered = search.isEmpty() ? all : all.filter(condition.bind(_, search));
      return Promise.value(limit.cata(filtered, fn(filtered.slice(0, _))));
    }
  }

  public static inline function async<Sug>(opts: AsyncAutocompleteOptions<Sug, Sug>): AppConfig<Sug, String, StringOrValue<Sug>> {
    return asyncMapToValue(opts, thx.Functions.identity);
  }

  public static inline function sync<Sug>(opts: SyncAutocompleteOptions<Sug, Sug>): AppConfig<Sug, String, StringOrValue<Sug>> {
    return create(
      filterSync(opts.suggestions, opts.filter, Options.ofValue(opts.limit)),
      opts.sugEq,
      thx.Functions.identity,
      Options.ofValue(opts.initValue),
      opts.initFilter,
      opts.minLength,
      opts.alwaysHighlight
    );
  }

  /**
   *  Useful when your value type is different from the Suggestion type, but
   *  you can easily map from Sug to Value.
   */
  public static inline function asyncMapToValue<Sug, Val>(
    opts: AsyncAutocompleteOptions<Sug, Val>,
    toValue: Sug -> Val
  ): AppConfig<Sug, String, StringOrValue<Val>> {
    return create(
      opts.filterer,
      opts.sugEq,
      toValue,
      Options.ofValue(opts.initValue),
      opts.initFilter,
      opts.minLength,
      opts.alwaysHighlight
    );
  }
}
