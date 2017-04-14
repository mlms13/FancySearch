package test.fancy;

import haxe.ds.Option;
using thx.Functions;
using thx.Options;
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

  static var simpleConfig: Configuration<String> = {
    filterer: StringDefaults.filterStringsSync(suggestions),
    renderView: StringDefaults.renderStringElement,
    renderString: thx.Functions.identity,
    clearButton: None,
    minLength: 0,
    alwaysHighlight: true
  };

  public function new() {}

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

    search.store.stream()
    .map.fn(_.menu)
    .take(3)
    .collectAll()
    .next(function (val) {
      var expectedSuggestions = thx.Nel.fromArray(suggestions.map(Suggestion)).get();
      Assert.same([Closed, Open(Loading), Open(Results(expectedSuggestions, None))], val);
    })
    .always(Assert.createAsync())
    .run();

    search.store.dispatch(OpenMenu);
  }
}
