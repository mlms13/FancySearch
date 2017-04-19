package fancy.search.renderer;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create;
using thx.Arrays;
import thx.Lazy;
using thx.Options;

import fancy.Search;
import fancy.search.Action;
import fancy.search.util.Configuration;
import fancy.search.util.ClassNameConfig;
import fancy.search.util.KeyboardConfig;

typedef RenderConfig<Sug, Filter> = {
  classes: ClassNameConfig,
  keys: KeyboardConfig,
  parseInput: String -> Option<Filter>,
  renderInput: Option<Filter> -> String,
  clearButton: Option<Lazy<Element>>, // TODO...
  renderSuggestion: Sug -> Element
};

class Dom {
  // render the item; apply special treatment if it matches the highlighted element
  static function renderMenuItem<Sug, Filter, Value>(config: Configuration<Sug, Filter, Value>, renderCfg: RenderConfig<Sug, Filter>, dispatch: Action<Sug, Filter, Value> -> Void, highlighted: Option<Sug>, sugg: Sug): Element {
    var highlightClass = highlighted.cata("",  function (h) {
      // if a highlight exists and it matches the stringified version of this suggestion
      // return the highglight class
      return config.sugEq(sugg, h) ? renderCfg.classes.itemHighlighted : "";
    });
    var li = create("li", [ "class" => renderCfg.classes.item + " " + highlightClass, ], [ renderCfg.renderSuggestion(sugg) ]);
    li.on("mouseover", function () dispatch(ChangeHighlight(Specific(sugg))));
    li.on("mouseup", function () {dispatch(ChooseCurrent); });
    return li;
  }

  static function renderMenu<Sug, Filter, A>(cfg: RenderConfig<Sug, Filter>, dispatch: Action<Sug, Filter, A> -> Void, state: State<Sug, Filter, A>): Element {
    return switch state.menu {
      case Closed(Inactive): create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerClosed]);
      case Closed(FailedCondition(reason)): create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerTooShort], reason); // TODO
      case Open(Loading, _): create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerLoading], "LOADING"); // TODO
      case Open(NoResults, _): create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerNoResults], "NO RESULTS"); // TODO
      case Open(Failed, _): create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerFailed], "FAILED"); // TODO
      case Open(Results(suggs), highlighted):
        var div = create("div", ["class" => cfg.classes.container + " " + cfg.classes.containerOpen], [
          create("ul", ["class" => cfg.classes.list], suggs.map(renderMenuItem.bind(state.config, cfg, dispatch, highlighted))
            .toArray().toArray()) // first to ReadonlyArray, then to a real one
        ]);
        div.on("mouseout", function () dispatch(ChangeHighlight(Unhighlight)));
        div;
    };
  }

  public static function fromInput<Sug, Filter, Val>(input: InputElement, container: Element, search: Search<Sug, Filter, Val>, cfg: RenderConfig<Sug, Filter>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu.bind(cfg, function (act) search.store.dispatch(act)));

    // cache this value so that we can dispatch it as the first chosen value
    // if the choose function doesn't like this value, the input will be cleared
    var initVal = input.value;

    // search.values.next(function (selected: Value) {
    //   switch selected {
    //     case Suggestion();
    //   };
    //   input.value = cfg.renderInput(inputVal);
    // }).run();

    input.on("focus", function (_) search.store.dispatch(OpenMenu));
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) {
      switch cfg.parseInput(input.value) {
        case Some(v): search.store.dispatch(SetFilter(v));
        case None: // ignore input that can't be parsed to `Filter`
      }
    });
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

    // initially kick things off by setting the input value
    // search.store.dispatch();
    return menu;
  }
}
