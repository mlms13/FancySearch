package test.fancy;

import haxe.ds.Option;
using thx.Functions;
using thx.Nel;
using thx.Options;
import thx.stream.Stream;
import thx.stream.Store;
import utest.Assert;

import fancy.Search2;
import fancy.search.State;
import fancy.search.Action;
import fancy.search.util.Configuration;
import fancy.search.util.StringDefaults;

class TestSearch {
  static var suggestions = [
    "Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
      "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
      "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
      "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"
  ];

  // technically unsafe, but you can see with your eyes that it's fine...
  static var suggestionsNel = Nel.fromArray(suggestions.map(Suggestion)).get();

  static var simpleConfig: Configuration<String> = {
    filterer: StringDefaults.filterStringsSync(suggestions),
    renderView: StringDefaults.renderStringElement,
    renderString: thx.Functions.identity,
    clearButton: None,
    minLength: 0,
    alwaysHighlight: true
  };

  public function new() {}

  inline static function collectMenuState<T>(store: Store<State<T>, Action<T>>, howMany: Int): Stream<Array<MenuState<T>>> {
    return store.stream().map.fn(_.menu).take(howMany).collectAll();
  }

  // kick it off with an easy one
  public function testInitialState() {
    var search = new Search2(simpleConfig);

    search.store.stream()
      .take(1)
      .next(function (val) {
        Assert.same(simpleConfig, val.config);
        Assert.same(None, val.input);
        Assert.same(Closed, val.menu);
      })
      .always(Assert.createAsync())
      .run();
  }

  // make sure the middleware loads suggestions when appropriate
  public function testFocusInput() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 3)
      .next(function (val) {
        Assert.same([Closed, Open(Loading), Open(Results(suggestionsNel, None))], val);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
  }

  // changing the input value should filter results
  public function testFilterResults() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 5)
      .next(function (val) {
        var expected = [
          Closed,
          Open(Loading),
          Open(Results(suggestionsNel, None)),
          Open(Loading), // back to loading when value changes
          Open(Results(Nel.pure(Suggestion("Zucchini")), None))
        ];

        Assert.same(expected, val);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeValue("z"));
  }

  // delayed results should behave the same as above, but...
  // if the menu is closed before results load, it should stay closed
  public function testDelayedResults() {
    var config = thx.Objects.clone(simpleConfig);
    config.filterer = function (optString) {
      return thx.promise.Promise.nil.delay(20)
        .flatMap(function (_) return StringDefaults.filterStringsSync(suggestions)(optString));
    };

    var searchA = new Search2(config);
    var searchB = new Search2(config);

    // behaves the same as above...
    collectMenuState(searchA.store, 3)
      .next(function (v) {
        var expected = [Closed, Open(Loading), Open(Results(suggestionsNel, None))];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    searchA.store.dispatch(OpenMenu);

    // stays closed
    collectMenuState(searchB.store, 4)
      .next(function (v) {
        var expected = [
          Closed,
          Open(Loading),
          Closed, // closed when we tell it to close
          Closed // and still closed when we finish loading results
        ];

        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    searchB.store.dispatch(OpenMenu);
    searchB.store.dispatch(CloseMenu);
  }
}