package fancy.search.renderer;

import haxe.ds.Option;
import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create;
using thx.Arrays;
using thx.Options;

import fancy.search.Action;
import fancy.search.util.Configuration;

class Dom {
  // TODO: expose this as configuration
  static var prefix = "fs-suggestion";
  static var containerPrefix = prefix + "-container";
  static var classes = {
    container: containerPrefix,
    containerClosed: containerPrefix + "-closed",
    containerOpen: containerPrefix + "-open",
    containerTooShort: containerPrefix + "-too-short",
    containerNoResults: containerPrefix + "-empty",
    containerLoading: containerPrefix + "-loading",
    containerFailed: containerPrefix + "-failed",
    list: prefix + "-list",
    label: prefix + "-label",
    item: prefix + "-item",
    itemHighlighted: prefix + "-item-highlighted"
  };
  static var keys = {
    highlightUp: [dots.Keys.UP_ARROW],
    highlightDown: [dots.Keys.DOWN_ARROW],
  };

  // render the item; apply special treatment if it matches the highlighted element
  static function renderMenuItem<T>(config: Configuration<T>, dispatch: Action<T> -> Void, highlighted: Option<T>, sugg: SuggestionItem<T>): Element {
    return switch sugg {
      case Suggestion(s):
        var highlightClass = highlighted.cata("",  function (h: T) {
          // if a highlight exists and it matches the stringified version of this suggestion
          // return the highglight class
          return config.equals(s, h) ? classes.itemHighlighted : "";
        });
        var li = create("li", [ "class" => classes.item + " " + highlightClass, ], [ config.renderView(s) ]);
        li.on("mouseover", function () dispatch(ChangeHighlight(Specific(s))));
        li;
      case Label(renderer):
        create("li", ["class" => classes.label], [ renderer() ]);
    };
  }

  static function renderMenu<T>(dispatch: Action<T> -> Void, state: State<T>): Element {
    return switch state.menu {
      case Closed: create("div", ["class" => classes.container + " " + classes.containerClosed]);
      case InputTooShort: create("div", ["class" => classes.container + " " + classes.containerTooShort]);
      case Open(Loading, _): create("div", ["class" => classes.container + " " + classes.containerLoading], "LOADING"); // TODO
      case Open(NoResults, _): create("div", ["class" => classes.container + " " + classes.containerNoResults], "NO RESULTS"); // TODO
      case Open(Failed, _): create("div", ["class" => classes.container + " " + classes.containerFailed], "FAILED"); // TODO
      case Open(Results(suggs), highlighted):
        var div = create("div", ["class" => classes.container + " " + classes.containerOpen], [
          create("ul", ["class" => classes.list], suggs.map(renderMenuItem.bind(state.config, dispatch, highlighted))
            .toArray().toArray()) // first to ReadonlyArray, then to a real one
        ]);
        div.on("mouseout", function () dispatch(ChangeHighlight(Unhighlight)));
        div;
    };
  }

  public static function fromInput<T>(input: InputElement, container: Element, search: fancy.Search2<T>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu.bind(function (act) search.store.dispatch(act)));

    input.on("focus", function (_) search.store.dispatch(OpenMenu));
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) search.store.dispatch(ChangeValue(input.value)));
    input.on("keydown", function (e: js.html.KeyboardEvent) {
      e.stopPropagation();
      var code = e.which != null ? e.which : e.keyCode;

      if (keys.highlightUp.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Up)));
      } else if (keys.highlightDown.contains(code)) {
        search.store.dispatch(ChangeHighlight(Move(Down)));
      }

    });

    // initially kick things off by setting the input value
    search.store.dispatch(ChangeValue(input.value));

    return menu;
  }

  // public static function fromContainer(container: Element, config: Configuration<T>): fancy.Search2<T> {
  // TODO: create an input, attach it to the container, pass this into fromInput
  // }
}
