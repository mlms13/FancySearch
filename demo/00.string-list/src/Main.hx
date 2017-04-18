
import haxe.ds.Option;
import js.html.Element;
using thx.Strings;
import fancy.search.util.StringDefaults;
import fancy.search.util.Configuration;

class Main {
  static function main() {
    var config: Configuration<String, String> = {
      filterer: StringDefaults.filterStringsSync([
        "Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
          "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
          "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
          "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"
      ]),
      renderView: StringDefaults.renderStringElement,
      choose: function (inputOpt, suggOpt) {
        return suggOpt; // new input
      },
      select: function (input) trace(input),
      equals: function (a, b) return a == b,
      clearButton: None,
      hideMenuCondition: thx.fp.Functions.const(None),
      alwaysHighlight: false
    };

    var container: Element = dots.Query.find(".fancy-container");
    var input = dots.Query.find(".fancy-container input");
    var search = new fancy.Search2(config);

    var renderer = fancy.search.renderer.Dom.fromInput(input, container, search, function (str) return str.isEmpty() ? None : Some(str));

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
