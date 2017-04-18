package test.fancy;

import haxe.ds.Option;
using thx.Functions;
using thx.Nel;
using thx.Options;
import thx.promise.Promise;
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

  static var simpleConfig: Configuration<String, String> = {
    filterer: StringDefaults.filterStringsSync(suggestions),
      renderView: StringDefaults.renderStringElement,
      choose: function (inputOpt, suggOpt) {
        return suggOpt; // new input
      },
      equals: function (a, b) return a == b,
      clearButton: None,
      hideMenuCondition: thx.fp.Functions.const(None),
      alwaysHighlight: false
  };

  public function new() {}

  inline static function collectMenuState<T, TValue>(store: Store<State<T, TValue>, Action<T, TValue>>, howMany: Int): Stream<Array<MenuState<T>>> {
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
        Assert.same(Closed(Inactive), val.menu);
      })
      .always(Assert.createAsync())
      .run();
  }

  ////////////////////////////////////////////////////////////////////////////////
  // TEST LOADING RESULTS
  ////////////////////////////////////////////////////////////////////////////////

  // make sure the middleware loads suggestions when appropriate
  public function testFocusInput() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 3)
      // .log()
      .next(function (val) {
        Assert.same([Closed(Inactive), Open(Loading, None), Open(Results(suggestionsNel), None)], val);
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
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), None),
          Open(Loading, None), // back to loading when value changes
          Open(Results(Nel.pure(Suggestion("Zucchini"))), None)
        ];

        Assert.same(expected, val);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeValue(Some("z")));
  }

  // delayed results should behave the same as above, but...
  // if the menu is closed before results load, it should stay closed
  public function testDelayedResults() {
    var config = thx.Objects.clone(simpleConfig);
    config.filterer = function (optString) {
      return Promise.nil.delay(20)
        .flatMap(function (_) return StringDefaults.filterStringsSync(suggestions)(optString));
    };

    var searchA = new Search2(config);
    var searchB = new Search2(config);

    // behaves the same as above...
    collectMenuState(searchA.store, 3)
      .next(function (v) {
        var expected = [Closed(Inactive), Open(Loading, None), Open(Results(suggestionsNel), None)];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    searchA.store.dispatch(OpenMenu);

    // stays closed
    collectMenuState(searchB.store, 4)
      .next(function (v) {
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Closed(Inactive), // closed when we tell it to close
          Closed(Inactive) // and still closed when we finish loading results
        ];

        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    searchB.store.dispatch(OpenMenu);
    searchB.store.dispatch(CloseMenu);
  }

  // when the filterer fails, the state should reflect that
  public function testFailedResults() {
    var config = thx.Objects.clone(simpleConfig);
    config.filterer = function (_) return Promise.fail("failed");

    var search = new Search2(config);

    collectMenuState(search.store, 3)
      .next(function (v) {
        Assert.same([Closed(Inactive), Open(Loading, None), Open(Failed, None)], v);
      })
      .always(Assert.createAsync())
      .run();
    search.store.dispatch(OpenMenu);
  }

  //////////////////////////////////////////////////////////////////////////////
  // TEST HIGHLIGHT
  //////////////////////////////////////////////////////////////////////////////

  // enabling the `alwaysHighlight` feature should lead to `Some(highlight)`
  // without manually changing the highlight
  public function testAlwaysHighlighted() {
    var config = thx.Objects.clone(simpleConfig);
    config.alwaysHighlight = true;

    var search = new Search2(config);

    collectMenuState(search.store, 3)
      .next(function (v) {
        Assert.same([Closed(Inactive), Open(Loading, None), Open(Results(suggestionsNel), Some("Apple"))], v);
      })
      .always(Assert.createAsync())
      .run();
    search.store.dispatch(OpenMenu);
  }

  // allow changing the highlight to a specific value (mimicing mouse hover)
  public function testHighlightSpecific() {
    var search = new Search2(simpleConfig);

    collectMenuState(search.store, 4)
      .next(function (v) {
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), None),
          Open(Results(suggestionsNel), Some("Corn"))
        ];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeHighlight(Specific("Corn")));
  }

  // subsequent changes should preserve your highlight if the field
  // you highlighted is still in the list after changes
  public function testSearchAfterHighlight() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 6)
      .next(function (v) {
        var results = Nel.nel("Black Bean", ["Fava Beans", "Lima Bean"]).map(Suggestion);
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), None),
          Open(Results(suggestionsNel), Some("Fava Beans")),
          Open(Loading, Some("Fava Beans")),
          Open(Results(results), Some("Fava Beans"))
        ];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeHighlight(Specific("Fava Beans")));
    search.store.dispatch(ChangeValue(Some("bean")));
  }

  // ...but, if input changes made your highlight no longer part of the results
  // highlight `None`
  public function testHighlightNotMatching() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 6)
      .next(function (v) {
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), None),
          Open(Results(suggestionsNel), Some("Fava Beans")),
          Open(Loading, Some("Fava Beans")),
          Open(Results(Nel.pure(Suggestion("Zucchini"))), None)
        ];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeHighlight(Specific("Fava Beans")));
    search.store.dispatch(ChangeValue(Some("z")));
  }

  // ...unless `alwaysHighlight` is true, in which case the first is highlighted
  public function testAlwaysHighlightNotMatching() {
    var config = thx.Objects.clone(simpleConfig);
    config.alwaysHighlight = true;
    var search = new Search2(config);
    collectMenuState(search.store, 6)
      .next(function (v) {
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), Some("Apple")),
          Open(Results(suggestionsNel), Some("Fava Beans")),
          Open(Loading, Some("Fava Beans")),
          Open(Results(Nel.pure(Suggestion("Zucchini"))), Some("Zucchini"))
        ];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeHighlight(Specific("Fava Beans")));
    search.store.dispatch(ChangeValue(Some("z")));
  }

  // in `alwaysHighlight` mode, ignore unhighlight
  public function testAlwaysHighlightUnhighlight() {
    var config = thx.Objects.clone(simpleConfig);
    config.alwaysHighlight = true;
    var search = new Search2(config);

    collectMenuState(search.store, 5)
      .next(function (v) {
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), Some("Apple")),
          Open(Results(suggestionsNel), Some("Black Bean")),
          Open(Results(suggestionsNel), Some("Black Bean"))
        ];

        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeHighlight(Specific("Black Bean")));
    search.store.dispatch(ChangeHighlight(Unhighlight));
  }

  // test moving the highlight up and down
  public function testMoveHighlight() {
    var search = new Search2(simpleConfig);
    collectMenuState(search.store, 10)
      .next(function (v) {
        var results = Nel.nel("Black Bean", ["Fava Beans", "Lima Bean"]).map(Suggestion);
        var expected = [
          Closed(Inactive),
          Open(Loading, None),
          Open(Results(suggestionsNel), None),
          Open(Loading, None),
          Open(Results(results), None),
          Open(Results(results), Some("Black Bean")),
          Open(Results(results), Some("Fava Beans")),
          Open(Results(results), Some("Lima Bean")),
          Open(Results(results), Some("Black Bean")),
          Open(Results(results), Some("Lima Bean"))
        ];
        Assert.same(expected, v);
      })
      .always(Assert.createAsync())
      .run();

    search.store.dispatch(OpenMenu);
    search.store.dispatch(ChangeValue(Some("bean")));
    search.store.dispatch(ChangeHighlight(Move(Down)));
    search.store.dispatch(ChangeHighlight(Move(Down)));
    search.store.dispatch(ChangeHighlight(Move(Down)));
    search.store.dispatch(ChangeHighlight(Move(Down)));
    search.store.dispatch(ChangeHighlight(Move(Up)));
  }
}
