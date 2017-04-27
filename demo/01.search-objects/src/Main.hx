import haxe.ds.Option;
import dots.Dom.create;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.config.AppConfig;
import fancy.search.defaults.AllString;
import fancy.search.defaults.ClassNameDefaults;
import fancy.search.defaults.KeyboardDefaults;

typedef Person = {
  firstName: String,
  lastName: String,
  github: String
};

class Main {
  static function main() {
    var people: Array<Person> = [
      { firstName: "Michael", lastName: "Martin", github: "mlms13" },
      { firstName: "Franco", lastName: "Ponticelli", github: "fponticelli" },
      { firstName: "Andy", lastName: "White", github: "andywhite37" },
    ];

    var config: AppConfig<Person, String, Option<Person>> = {
      filterer: makeFilterer(people),
      sugEq: function (a, b) return a.github == b.github,
      initFilter: "",
      initValue: None,
      allowMenu: thx.fp.Functions.const(Allow),
      alwaysHighlight: true,
      getValue: function (highlight: Option<Person>, _, curr: Option<Person>) {
        return highlight.orElse(curr);
      }
    };

    var container: js.html.Element = dots.Query.find(".fancy-container");
    var input = dots.Query.find(".fancy-container input");
    var search = new fancy.Search(config);

    var renderer = fancy.search.renderer.DomStringFilter.fromInput(input, container, search, {
      classes: fancy.search.defaults.ClassNameDefaults.defaults,
      keys: fancy.search.defaults.KeyboardDefaults.defaults,
      renderSuggestion: function (p: Person, filter: String): js.html.Element {
        return create("div", [
          create("div", p.firstName + " " + p.lastName),
          create("div", [ "style" => "color: #aaa; "], p.github)
        ]);
      },
      elements: {
        clearButton: None,
        failedCondition: None,
        loading: None,
        failed: None,
        noResults: Some(function () return dots.Dom.create("span", "No Results"))
      }
    });

    renderer.next(function (dom) {
      // remove all children except the first (input)
      while (container.children.length > 1) {
        container.removeChild(container.lastChild);
      }

      // then append the new content after the input
      dots.Dom.append(container, [ dom ]);
    }).run();

    search.values.next(function (val: Option<Person>) {
      input.value = val.cata("", personToString);
    }).run();
  }

  static function personToString(p: Person): String {
    return p.firstName + " " + p.lastName + " " + p.github;
  }

  static function makeFilterer(people: Array<Person>): Filterer<Person, String> {
    return function filterer(search: String): Promise<Array<Person>> {
      return Promise.value(search.isEmpty() ? people : people.filter(function (p) {
        return personToString(p).caseInsensitiveContains(search);
      }));
    }
  }
}
