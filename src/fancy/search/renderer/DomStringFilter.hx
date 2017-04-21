package fancy.search.renderer;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create as c;
using thx.Arrays;
import thx.Lazy;
using thx.Options;

import fancy.Search;
import fancy.search.Action;
import fancy.search.config.AppConfig;
import fancy.search.config.RendererConfig;

class DomStringFilter {
  public static function renderStringSuggestion(sugg: String) {
    return c("li", sugg);
  }

  // render the item; apply special treatment if it matches the highlighted element
  static function renderMenuItem<Sug, Value>(config: AppConfig<Sug, String, Value>, renderCfg: RendererConfig<Sug, Element>, dispatch: Action<Sug, String, Value> -> Void, highlighted: Option<Sug>, sugg: Sug): Element {
    var highlightClass = highlighted.cata("",  function (h) {
      // if a highlight exists and it matches the stringified version of this suggestion
      // return the highglight class
      return config.sugEq(sugg, h) ? renderCfg.classes.itemHighlighted : "";
    });
    var li = c("li", [ "class" => renderCfg.classes.item + " " + highlightClass, ], [ renderCfg.renderSuggestion(sugg) ]);
    li.on("mouseover", function () dispatch(ChangeHighlight(Specific(sugg))));
    li.on("mouseup", function () {dispatch(ChooseCurrent); });
    return li;
  }

  static function renderMenu<Sug, A>(cfg: RendererConfig<Sug, Element>, dispatch: Action<Sug, String, A> -> Void, state: State<Sug, String, A>): Element {
    return switch state.menu {
      case Closed(Inactive): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerClosed]);
      case Closed(FailedCondition(reason)): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerTooShort], reason); // TODO
      case Open(Loading, _): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerLoading], "LOADING"); // TODO
      case Open(NoResults, _): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerNoResults], "NO RESULTS"); // TODO
      case Open(Failed, _): c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerFailed], "FAILED"); // TODO
      case Open(Results(suggs), highlighted):
        var div = c("div", ["class" => cfg.classes.container + " " + cfg.classes.containerOpen], [
          c("ul", ["class" => cfg.classes.list], suggs.map(renderMenuItem.bind(state.config, cfg, dispatch, highlighted))
            .toArray().toArray()) // first to ReadonlyArray, then to a real one
        ]);
        div.on("mouseout", function () dispatch(ChangeHighlight(Unhighlight)));
        div;
    };
  }

  public static function fromInput<Sug, Val>(input: InputElement, container: Element, search: Search<Sug, String, Val>, cfg: RendererConfig<Sug, Element>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu.bind(cfg, function (act) search.store.dispatch(act)));

    input.on("focus", function (_) search.store.dispatch(SetFilter(input.value)));
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) search.store.dispatch(SetFilter(input.value)));
    input.on("keydown", function (e: js.html.KeyboardEvent) {
      e.stopPropagation();
      var code = e.which != null ? e.which : e.keyCode;

      if (cfg.keys.highlightUp.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Up)));
      } else if (cfg.keys.highlightDown.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Down)));
      } else if (cfg.keys.choose.contains(code)) {
        search.store.dispatch(ChooseCurrent);
      }
    });

    return menu;
  }
}
