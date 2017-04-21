
import haxe.ds.Option;

import fancy.search.State;
import fancy.search.Action;
import fancy.search.config.RendererConfig;
import fancy.search.defaults.AllString;
import fancy.search.renderer.DoomAutocomplete;

class Main {
  static function main() {
    var foods: Array<String> = [
      "Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
      "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
      "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
      "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"
    ];
    var search = new fancy.Search(AllString.sync({ suggestions: foods }));
    var rendererConfig: RendererConfig<String, doom.core.VNode> = {
      renderSuggestion: function (sugg: String) {
        return doom.html.Html.div(sugg);
      },
      keys: fancy.search.defaults.KeyboardDefaults.defaults,
      classes: fancy.search.defaults.ClassNameDefaults.defaults,
      elements: {
        clearButton: None,
        failedCondition: None,
        loading: None,
        failed: None,
        noResults: Some(function () return doom.html.Html.span("No Results"))
      },
    };
    var dispatch = function (act: Action<String, String, String>) {
      search.store.dispatch(act);
    }

    var vnodes = search.store.stream().map(function (state: State<String, String, String>) {
      return DoomAutocomplete.render({
        state: state,
        cfg: rendererConfig,
        dispatch: dispatch
      });
    });

    Doom.browser.stream(vnodes, js.Browser.document.querySelector(".fancy-container"));
  }
}
