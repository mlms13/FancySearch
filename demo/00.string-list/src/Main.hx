
import haxe.ds.Option;
import js.html.Element;
using thx.Options;
using thx.Strings;
import fancy.search.util.StringDefaults;
import fancy.search.util.Configuration;
import fancy.search.util.ClassNameConfig;
import fancy.search.util.KeyboardConfig;

class Main {
  static function main() {
    var config: Configuration<String, String> = {
      filterer: StringDefaults.filterStringsSync([
        "Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
          "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
          "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
          "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"
      ]),
      equals: function (a, b) return a == b,
      hideMenuCondition: thx.fp.Functions.const(None),
      alwaysHighlight: false
    };

    var container: Element = dots.Query.find(".fancy-container");
    var input = dots.Query.find(".fancy-container input");
    var search = new fancy.Search(config);

    var renderer = fancy.search.renderer.Dom.fromInput(input, container, search, {
      classes: ClassNameConfigs.defaultClasses,
      keys: KeyboardConfigs.defaultKeys,
      parseInput: function (str) return str.isEmpty() ? None : Some(str),
      renderInput: function (input) return input.getOrElse(""),
      clearButton: None,
      renderSuggestion: StringDefaults.renderStringElement
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
}
