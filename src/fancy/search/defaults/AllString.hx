package fancy.search.defaults;

import haxe.ds.Option;
import thx.Functions.fn;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.config.AppConfig;
import fancy.search.defaults.AutocompleteDefaults;

typedef SyncStringOptions = {
  suggestions: Array<String>,
  ?minLength: Int,
  ?alwaysHighlight: Bool,
  ?limit: Int
};

class AllString {
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
  public static inline function filterStringsSync(all: Array<String>, limit: Option<Int>): Filterer<String, String> {
    // this default filterer doesn't resort based on relevance. since we know
    // we're sorting strings, we could do a more specialized filter that
    // prioritizes results where the search string is closer to index 0.
    return AutocompleteDefaults.filterSync(all, Strings.caseInsensitiveContains, limit);
  }

  //////////////////////////////////////////////////////////////////////////////
  // Configuration constructors
  //////////////////////////////////////////////////////////////////////////////

  public static function sync(opts: SyncStringOptions): AppConfig<String, String, StringOrSuggestion<String>> {
    return AutocompleteDefaults.sync({
      suggestions: opts.suggestions,
      filter: Strings.caseInsensitiveContains,
      limit: opts.limit,
      sugEq: Strings.order.equal,
      minLength: opts.minLength,
      alwaysHighlight: opts.alwaysHighlight
    });
  }
}
