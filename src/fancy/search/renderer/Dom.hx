package fancy.search.renderer;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create;
using thx.Arrays;
import thx.Lazy;
using thx.Options;

import fancy.search.Action;
import fancy.search.util.Configuration;
import fancy.search.util.ClassNameConfig;
import fancy.search.util.KeyboardConfig;

typedef RenderConfig<TSugg, TValue> = {
  classes: ClassNameConfig,
  keys: KeyboardConfig,
  parseInput: String -> Option<TValue>,
  renderInput: Option<TValue> -> String,
  clearButton: Option<Lazy<Element>>, // TODO...
  renderSuggestion: TSugg -> Element
};

class Dom {
  // render the item; apply special treatment if it matches the highlighted element
  static function renderMenuItem<T, TI>(config: Configuration<T, TI>, renderCfg: RenderConfig<T, TI>, dispatch: Action<T, TI> -> Void, highlighted: Option<T>, sugg: SuggestionItem<T>): Element {
    return switch sugg {
      case Suggestion(s):
        var highlightClass = highlighted.cata("",  function (h: T) {
          // if a highlight exists and it matches the stringified version of this suggestion
          // return the highglight class
          return config.equals(s, h) ? renderCfg.classes.itemHighlighted : "";
        });
        var li = create("li", [ "class" => renderCfg.classes.item + " " + highlightClass, ], [ renderCfg.renderSuggestion(s) ]);
        li.on("mouseover", function () dispatch(ChangeHighlight(Specific(s))));
        li.on("mouseup", function () {dispatch(Choose(Some(s), None)); });
        li;
      case Label(renderer):
        create("li", ["class" => renderCfg.classes.label], [ renderer() ]);
    };
  }

  static function renderMenu<T, TValue>(cfg: RenderConfig<T, TValue>, dispatch: Action<T, TValue> -> Void, state: State<T, TValue>): Element {
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

  public static function fromInput<T, TValue>(input: InputElement, container: Element, search: fancy.Search2<T, TValue>, cfg: RenderConfig<T, TValue>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu.bind(cfg, function (act) search.store.dispatch(act)));

    // cache this value so that we can dispatch it as the first chosen value
    // if the choose function doesn't like this value, the input will be cleared
    var initVal = input.value;

    search.stream.next(function (inputVal: Option<TValue>) {
      input.value = cfg.renderInput(inputVal);
    }).run();

    input.on("focus", function (_) search.store.dispatch(OpenMenu));
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) search.store.dispatch(ChangeValue(cfg.parseInput(input.value))));
    input.on("keydown", function (e: js.html.KeyboardEvent) {
      e.stopPropagation();
      var code = e.which != null ? e.which : e.keyCode;
      var highlighted = switch search.store.get().menu {
        case Open(_, highlight): highlight;
        case _: None;
      };

      if (cfg.keys.highlightUp.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Up)));
      } else if (cfg.keys.highlightDown.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Down)));
      } else if (cfg.keys.choose.contains(code)) {
        search.store.dispatch(switch highlighted {
          case None: Choose(None, cfg.parseInput(input.value));
          case _: Choose(highlighted, None);
        });
      }
    });

    // initially kick things off by setting the input value
    search.store.dispatch(Choose(None, cfg.parseInput(initVal)));
    return menu;
  }
}
