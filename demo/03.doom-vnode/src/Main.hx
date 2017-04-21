
import haxe.ds.Option;

import fancy.search.State;
import fancy.search.config.RendererConfig;
import fancy.search.defaults.AllString;
import fancy.search.renderer.DoomStringFilter;

class Main {
  static function main() {
    var foods: Array<String> = ["Bread", "Beans", "Celery"];
    var search = new fancy.Search(AllString.sync({ suggestions: foods }));
    var rendererConfig: RendererConfig<String, doom.core.VNode> = {
      renderSuggestion: function (sugg: String) {
        return doom.html.Html.div(sugg);
      },
      keys: fancy.search.defaults.KeyboardDefaults.defaults,
      classes: fancy.search.defaults.ClassNameDefaults.defaults,
      clearButton: None
    };

    var vnodes = search.store.stream().map(function (state: State<String, String, String>) {
      return new DoomStringFilter({ search: search, cfg: rendererConfig}).asNode();
    });

    Doom.browser.stream(vnodes, js.Browser.document.getElementById("app"));
  }
}
