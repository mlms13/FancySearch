
import haxe.ds.Option;
import js.html.Element;
using thx.Options;
using thx.Strings;

import fancy.search.renderer.DomStringFilter;
import fancy.search.config.AppConfig;

class Main {
  static function main() {
    var config: AppConfig<String, String, String> = fancy.search.defaults.AllString.sync({
      suggestions: [
        "Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
        "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
        "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
        "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"
      ],
      limit: 10,
      alwaysHighlight: true,
      onlySuggestions: true
    });

    var container: Element = dots.Query.find(".fancy-container");
    var input = dots.Query.find(".fancy-container input");
    var search = new fancy.Search(config);

    var renderer = DomStringFilter.fromInput(input, container, search, {
      classes: fancy.search.defaults.ClassNameDefaults.defaults,
      keys: fancy.search.defaults.KeyboardDefaults.defaults,
      clearButton: None,
      renderSuggestion: DomStringFilter.renderStringSuggestion
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
