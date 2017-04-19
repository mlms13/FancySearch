package test.fancy;

import haxe.ds.Option;
using thx.Functions;
using thx.Nel;
using thx.Options;
import thx.promise.Promise;
import thx.stream.Stream;
import thx.stream.Store;
import utest.Assert;

import fancy.Search;
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
  static var suggestionsNel = Nel.fromArray(suggestions).get();

  static var simpleConfig: Configuration<String, String, String> = {
    filterer: StringDefaults.filterStringsSync(suggestions, 50),
    sugEq: function (a, b) return a == b,
    allowMenu: thx.fp.Functions.const(Allow),
    initFilter: "",
    initValue: "",
    alwaysHighlight: false
  };

  public function new() {}

  inline static function assertStates<T>(stream: Stream<T>, expect: Array<T>) {
    stream.take(expect.length).collectAll()
      .next(function (v) Assert.same(expect, v))
      .always(Assert.createAsync())
      .run();
  }

  inline static function assertMenuStates<Sug, A, B>(store: Store<State<Sug, A, B>, Action<Sug, A, B>>, expect: Array<MenuState<Sug>>) {
    return assertStates(store.stream().map.fn(_.menu), expect);
  }

  // kick it off with an easy one
  public function testInitialState() {
    var search = new Search(simpleConfig);

    search.store.stream()
      .take(1)
      .next(function (val) {
        Assert.same(simpleConfig, val.config);
        Assert.same("", val.filter);
        Assert.same("", val.value);
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
    var search = new Search(simpleConfig);
    assertMenuStates(search.store, [Closed(Inactive), Open(Loading, None), Open(Results(suggestionsNel), None)]);
    search.store.dispatch(OpenMenu);
  }

  // changing the input value should filter results
  public function testFilterResults() {
    var search = new Search(simpleConfig);
    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), None),
      Open(Loading, None), // back to loading when value changes
      Open(Results(Nel.pure("Zucchini")), None)
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(SetFilter("z"));
  }

  // delayed results should behave the same as above, but...
  // if the menu is closed before results load, it should stay closed
  public function testDelayedResults() {
    var config = thx.Objects.clone(simpleConfig);
    config.filterer = function (str) {
      return Promise.nil.delay(20)
        .flatMap(function (_) return StringDefaults.filterStringsSync(suggestions, 50)(str));
    };

    var searchA = new Search(config);
    var searchB = new Search(config);

    // behaves the same as above...
    assertMenuStates(searchA.store, [Closed(Inactive), Open(Loading, None), Open(Results(suggestionsNel), None)]);
    searchA.store.dispatch(OpenMenu);

    // stays closed
    assertMenuStates(searchB.store, [
      Closed(Inactive),
      Open(Loading, None),
      Closed(Inactive), // closed when we tell it to close
      Closed(Inactive) // and still closed when we finish loading results
    ]);

    searchB.store.dispatch(OpenMenu).dispatch(CloseMenu);
  }

  // when the filterer fails, the state should reflect that
  public function testFailedResults() {
    var config = thx.Objects.clone(simpleConfig);
    config.filterer = function (_) return Promise.fail("failed");

    var search = new Search(config);
    assertMenuStates(search.store, [Closed(Inactive), Open(Loading, None), Open(Failed, None)]);
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

    var search = new Search(config);
    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel),
      Some("Apple"))
    ]);

    search.store.dispatch(OpenMenu);
  }

  // allow changing the highlight to a specific value (mimicing mouse hover)
  public function testHighlightSpecific() {
    var search = new Search(simpleConfig);

    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), None),
      Open(Results(suggestionsNel), Some("Corn"))
    ]);

    search.store.dispatch(OpenMenu).dispatch(ChangeHighlight(Specific("Corn")));
  }

  // subsequent changes should preserve your highlight if the field
  // you highlighted is still in the list after changes
  public function testSearchAfterHighlight() {
    var search = new Search(simpleConfig);
    var results = Nel.nel("Black Bean", ["Fava Beans", "Lima Bean"]);
    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), None),
      Open(Results(suggestionsNel), Some("Fava Beans")),
      Open(Loading, Some("Fava Beans")),
      Open(Results(results), Some("Fava Beans"))
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(ChangeHighlight(Specific("Fava Beans")))
      .dispatch(SetFilter("bean"));
  }

  // ...but, if input changes made your highlight no longer part of the results
  // highlight `None`
  public function testHighlightNotMatching() {
    var search = new Search(simpleConfig);
    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), None),
      Open(Results(suggestionsNel), Some("Fava Beans")),
      Open(Loading, Some("Fava Beans")),
      Open(Results(Nel.pure("Zucchini")), None)
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(ChangeHighlight(Specific("Fava Beans")))
      .dispatch(SetFilter("z"));
  }

  // ...unless `alwaysHighlight` is true, in which case the first is highlighted
  public function testAlwaysHighlightNotMatching() {
    var config = thx.Objects.clone(simpleConfig);
    config.alwaysHighlight = true;

    var search = new Search(config);
    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), Some("Apple")),
      Open(Results(suggestionsNel), Some("Fava Beans")),
      Open(Loading, Some("Fava Beans")),
      Open(Results(Nel.pure("Zucchini")), Some("Zucchini"))
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(ChangeHighlight(Specific("Fava Beans")))
      .dispatch(SetFilter("z"));
  }

  // in `alwaysHighlight` mode, ignore unhighlight
  public function testAlwaysHighlightUnhighlight() {
    var config = thx.Objects.clone(simpleConfig);
    config.alwaysHighlight = true;
    var search = new Search(config);

    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), Some("Apple")),
      Open(Results(suggestionsNel), Some("Black Bean")),
      Open(Results(suggestionsNel), Some("Black Bean"))
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(ChangeHighlight(Specific("Black Bean")))
      .dispatch(ChangeHighlight(Unhighlight));
  }

  // test moving the highlight up and down
  public function testMoveHighlight() {
    var search = new Search(simpleConfig);
    var results = Nel.nel("Black Bean", ["Fava Beans", "Lima Bean"]);

    assertMenuStates(search.store, [
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
    ]);

    search.store.dispatch(OpenMenu)
      .dispatch(SetFilter("bean"))
      .dispatch(ChangeHighlight(Move(Down)))
      .dispatch(ChangeHighlight(Move(Down)))
      .dispatch(ChangeHighlight(Move(Down)))
      .dispatch(ChangeHighlight(Move(Down)))
      .dispatch(ChangeHighlight(Move(Up)));
  }

  ////////////////////////////////////////////////////////////////////////////////
  // TEST SELECTION
  ////////////////////////////////////////////////////////////////////////////////

  public function testChooseSuggestion() {
    var search = new Search(simpleConfig);

    assertMenuStates(search.store, [
      Closed(Inactive),
      Open(Loading, None),
      Open(Results(suggestionsNel), None),
      Open(Results(suggestionsNel), Some("Corn")),
      Closed(Inactive) // closed after choosing
    ]);

    assertStates(search.values, ["Corn"]);

    search.store.dispatch(OpenMenu)
      .dispatch(ChangeHighlight(Specific("Corn")))
      .dispatch(ChooseCurrent);
  }
}
