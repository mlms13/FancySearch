package fancy.search.renderer;

import js.html.Element;
import js.html.InputElement;
using dots.Dom;
import dots.Dom.create;

import fancy.search.util.Configuration;

class Dom {
  static function renderMenuItem<T>(render: T -> Element, sugg: SuggestionItem<T>): Element {
    return create("li", [switch sugg {
      case Suggestion(sugg): render(sugg);
      case Label(renderer): renderer();
    }]);
  }

  static function renderMenu<T>(state: State<T>): Element {
    return switch state.menu {
      case Closed: create("div", ["class" => "closed"]);
      case InputTooShort: create("div", ["class" => "too-short"]);
      case Open(Loading): create("div", "LOADING"); // TODO
      case Open(NoResults): create("div", "NO RESULTS"); // TODO
      case Open(Results(suggs, highlighted)): create("div", ["class" => "open"], [
        create("ul", suggs.map(renderMenuItem.bind(state.config.renderView))
          .toArray().toArray()) // first to ReadonlyArray, then to a real one
      ]);
    };
  }

  public static function fromInput<T>(input: InputElement, container: Element, search: fancy.Search2<T>): thx.stream.Stream<Element> {
    var menu = search.store.stream().map(renderMenu);

    input.on("focus", function (_) search.store.dispatch(OpenMenu));
    input.on("blur", function (_) search.store.dispatch(CloseMenu));
    input.on("input", function (_) search.store.dispatch(ChangeValue(input.value)));

    // initially kick things off by setting the input value
    search.store.dispatch(ChangeValue(input.value));

    return menu;
  }

  // public static function fromContainer(container: Element, config: Configuration<T>): fancy.Search2<T> {
  // TODO: create an input, attach it to the container, pass this into fromInput
  // }
}
