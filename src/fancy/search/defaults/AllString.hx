package fancy.search.defaults;

import haxe.ds.Option;
import thx.Functions.fn;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.config.AppConfig;

typedef SyncStringConfigOptions = {
  suggestions: Array<String>,
  ?limit: Int,
  ?minLength: Int,
  ?onlySuggestions: Bool,
  ?alwaysHighlight: Bool
};

class AllString {
  static function create(
    filterer: String -> Promise<Array<String>>,
    ?minLength = 0,
    ?onlySuggestions = false,
    ?alwaysHighlight = true
  ): AppConfig<String, String, String> {
    return {
      filterer: filterer,
      sugEq: function (a, b) return a == b,
      allowMenu: function (filter: String) {
        return filter.length >= minLength ? Allow : Disallow("Input too short");
      },
      alwaysHighlight: alwaysHighlight,
      initValue: "",
      initFilter: "",
      getValue: function (highlight: Option<String>, filter: String, curr: String) {
        return highlight.getOrElse(onlySuggestions ? curr : filter);
      }
    };
  }

  //////////////////////////////////////////////////////////////////////////////
  // Property helpers
  //////////////////////////////////////////////////////////////////////////////

  /**
   *  Given an array of String suggestions, this returns a `Filterer` function,
   *  which can be used as a default filterer in a String-based Configuration.
   *  To use this, your suggestions must be of type String, and you must be
   *  willing to do all of your filtering synchronously on the client.
   *
   *  @param all - The complete list of strings to be filtered
   *  @param limit - Optionally slice the list down to something smaller
   *  @return Filterer<String>
   */
  public static function filterStringsSync(all: Array<String>, limit: Option<Int>): Filterer<String, String> {
    return function (search: String): Promise<Array<String>> {
      // TODO: could sort here, favoring matches near the beginning
      var filtered = search.isEmpty() ? all : all.filter(Strings.caseInsensitiveContains.bind(_, search));
      return Promise.value(limit.cata(filtered, fn(filtered.slice(0, _))));
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  // Configuration constructors
  //////////////////////////////////////////////////////////////////////////////

  public static function sync(opts: SyncStringConfigOptions): AppConfig<String, String, String> {
    return create(
      filterStringsSync(opts.suggestions, Options.ofValue(opts.limit)),
      opts.minLength,
      opts.onlySuggestions,
      opts.alwaysHighlight
    );
  }
}
