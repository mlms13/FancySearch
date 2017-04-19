import haxe.ds.Option;
import dots.Dom.create;
using thx.Options;
using thx.Strings;
import thx.promise.Promise;

import fancy.search.util.Configuration;
import fancy.search.util.StringDefaults;
import fancy.search.util.ClassNameConfig;
import fancy.search.util.KeyboardConfig;

enum SearchPerson {
  Text(search: String);
  Person(p: Person);
}

typedef Person = {
  firstName: String,
  lastName: String,
  github: String
};

class Main {
  static function main() {
    var people : Array<Person> = [
      { firstName: "Michael", lastName: "Martin", github: "mlms13" },
      { firstName: "Franco", lastName: "Ponticelli", github: "fponticelli" },
      { firstName: "Andy", lastName: "White", github: "andywhite37" },
    ];

    var config: Configuration<Person, SearchPerson> = {
      filterer: makeFilterer(people),
      equals: function (a, b) return a.github == b.github,
      hideMenuCondition: thx.fp.Functions.const(None),
      alwaysHighlight: true
    };

    var container: js.html.Element = dots.Query.find(".fancy-container");
    var input = dots.Query.find(".fancy-container input");
    var search = new fancy.Search(config);

    var renderer = fancy.search.renderer.Dom.fromInput(input, container, search, {
      classes: ClassNameConfigs.defaultClasses,
      keys: KeyboardConfigs.defaultKeys,
      parseInput: parseValue,
      renderInput: renderValue,
      renderSuggestion: function (p: Person): js.html.Element {
        return create("div", [
          create("div", p.firstName + " " + p.lastName),
          create("div", [ "style" => "color: #aaa; "], p.github)
        ]);
      },
      clearButton: None
    });

    renderer.next(function (dom) {
      // remove all children except the first (input)
      while (container.children.length > 1) {
        container.removeChild(container.lastChild);
      }

      // then append the new content after the input
      dots.Dom.append(container, [ dom ]);
    }).run();
  }

  static function renderValue(v: Option<SearchPerson>): String {
    return switch v {
      case None: "";
      case Some(Text(t)): t;
      case Some(Person(p)): personToString(p);
    };
  }

  static function parseValue(v: String): Option<SearchPerson> {
    return v.isEmpty() ? None : Some(Text(v)); // TODO? parse as a Person?
  }

  static function personToString(p: Person): String {
    return p.firstName + " " + p.lastName + " " + p.github;
  }

  static function makeFilterer(people: Array<Person>): Filterer<Person, SearchPerson> {
    return function filterer(search: Option<SearchPerson>): Promise<Array<SuggestionItem<Person>>> {
      return Promise.value(switch search {
        case None: people.map(Suggestion);
        case Some(Person(p)): [ Suggestion(p) ];
        case Some(Text(t)): people.filter(function (p) {
          return Strings.caseInsensitiveContains(personToString(p), t);
        }).map(Suggestion);
      });
    }
  }
}
