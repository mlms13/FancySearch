package fancy.search.renderer;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create as c;
using thx.Arrays;
import thx.Functions.fn;
import thx.Lazy;
using thx.Options;

import fancy.Search;
import fancy.search.Action;
import fancy.search.config.AppConfig;
import fancy.search.config.RendererConfig;

class DomStringFilter {
  public static function renderStringSuggestion(sugg: String, filter: String) {
    return c("li", sugg); // TODO: add emphasis
  }

  // render the item; apply special treatment if it matches the highlighted element
  static function renderMenuItem<Sug, Value>(config: AppConfig<Sug, String, Value>, renderCfg: RendererConfig<Sug, String, Element>, filter: String, dispatch: Action<Sug, String, Value> -> Void, highlighted: Option<Sug>, sugg: Sug): Element {
    var highlightClass = highlighted.cata("",  function (h) {
      // if a highlight exists and it matches the stringified version of this suggestion
      // return the highglight class
      return config.sugEq(sugg, h) ? renderCfg.classes.itemHighlighted : "";
    });
    var li = c("li", [ "class" => renderCfg.classes.item + " " + highlightClass, ], [ renderCfg.renderSuggestion(sugg, filter) ]);
    li.on("mouseover", function () dispatch(ChangeHighlight(Specific(sugg))));
    li.on("mouseup", function () {dispatch(ChooseCurrent); });
    return li;
  }

  static function renderMenu<Sug, A>(cfg: RendererConfig<Sug, String, Element>, dispatch: Action<Sug, String, A> -> Void, state: State<Sug, String, A>): Element {
    return switch state.menu {
      case Closed(Inactive): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerClosed]);
      case Closed(FailedCondition(reason)): c("div", [
        "class" => cfg.classes.container + " " + cfg.classes.containerNotAllowed
      ], cfg.elements.failedCondition.map(lazy -> lazy(reason)).toArray());
      case Open(Loading, _): c("div", [
        "class" => cfg.classes.container + " " + cfg.classes.containerLoading
      ], cfg.elements.loading.map(lazy -> lazy()).toArray());
      case Open(NoResults, _): c("div", [
        "class" => cfg.classes.container + " " + cfg.classes.containerNoResults
      ], cfg.elements.noResults.map(lazy -> lazy()).toArray());
      case Open(Failed, _): c("div", [
        "class" => cfg.classes.container + " " + cfg.classes.containerFailed
      ], cfg.elements.failed.map(lazy -> lazy()).toArray());
      case Open(Results(suggs), highlighted):
        var div = c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerOpen], [
          c("ul", ["class" => cfg.classes.list], suggs.toArray().map(renderMenuItem.bind(state.config, cfg, state.filter, dispatch, highlighted)))
        ]);
        div.on("mouseout", function () dispatch(ChangeHighlight(Unhighlight)));
        div;
    };
  }

  public static function fromInput<Sug, Val>(input: InputElement, search: Search<Sug, String, Val>, cfg: RendererConfig<Sug, String, Element>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu.bind(cfg, function (act) search.store.dispatch(act)));

    input.on("focus", function (_) {
      search.store.dispatch(SetFilter(input.value));
      search.store.dispatch(OpenMenu);
    });
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) search.store.dispatch(SetFilter(input.value)));
    input.on("keydown", function (e: js.html.KeyboardEvent) {
      var keyWithModifiers = dots.Keys.getKeyAndModifiers(e);
      if (cfg.keys.highlightUp(keyWithModifiers)) {
        e.stopPropagation();
        e.preventDefault();
        search.store.dispatch(ChangeHighlight(Move(Up)));
      } else if (cfg.keys.highlightDown(keyWithModifiers)) {
        e.stopPropagation();
        e.preventDefault();
        search.store.dispatch(ChangeHighlight(Move(Down)));
      } else if (cfg.keys.choose(keyWithModifiers)) {
        e.stopPropagation();
        e.preventDefault();
        search.store.dispatch(ChooseCurrent);
      } else if (cfg.keys.close(keyWithModifiers)) {
        e.stopPropagation();
        e.preventDefault();
        search.store.dispatch(CloseMenu);
      }
    });

    return menu;
  }
}
