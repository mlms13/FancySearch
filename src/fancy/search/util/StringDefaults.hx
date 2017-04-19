package fancy.search.util;

import haxe.ds.Option;
import js.html.Element;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.util.Configuration;

/**
 *  This class provides several static functions that can be used in your
 *  `Configuration` if your suggestion list is of type `String`.
 */
class StringDefaults {

  /**
   *  Given an array of String suggestions, this returns a `Filterer` function,
   *  which can be used as a simple default filterer in a `Configuration<String>`.
   *  To use this, your suggestions must be of type String, and you must be willing
   *  to do all of your filtering synchronously on the client.
   *
   *  @param suggestions - The complete list of strings to be filtered
   *  @return Filterer<String>
   */
  public static function filterStringsSync(suggestions: Array<String>, limit: Int): Filterer<String, String> {
    return function (search: String): Promise<Array<String>> {
      var filtered = search.isEmpty() ?
        suggestions :
        // TODO: could sort here, favoring matches near the beginning
        suggestions.filter(Strings.caseInsensitiveContains.bind(_, search));
      return Promise.value(filtered.slice(0, limit));
    }
  }

  public static function renderStringElement(suggestion: String): Element {
    return dots.Dom.create("span", suggestion);
  }
}
