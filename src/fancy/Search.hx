package fancy;

using dots.Dom;
import js.html.Element;
import js.html.InputElement;
import js.html.Event;
import js.html.KeyboardEvent;
import fancy.search.util.Types;
import fancy.search.*;
using thx.Arrays;
using thx.Objects;
using thx.Strings;
using thx.Options;

/**
  The `Search` class is the main entry point. It wires up event handlers along
  with the connection to the suggestion list. Its generic type match the type of
  the items passed as `SuggestionOptions.suggestions` to the
  constructor.

  A new FancySearch can be created using the constructor or one of the static
  factories below. In all cases, some means of accessing an input element must
  be provided, but all other options may be omitted.

  Apart from the constructor and factories, no public methods exist on this
  class. It does provide public access to its `Suggestions` in the form of:

  ```haxe
  myFancySearch.list;
  ```
**/
#if shallow-expose @:expose @:keep #end
class Search<T> {
  public var list(default, null): Suggestions<T>;
  public var input(default, null): InputElement;
  var clearBtn: Element;
  var settings: FancySearchSettings<T>;

  /**
    The constructor requires an input element which will be converted into a
    fancy search input (with appropriate event handlers bound to it). All other
    options are not required, but they allow you to modify the behavior of both
    the search input and the suggestion list.
  **/
  public function new(el: InputElement, ?options: FancySearchOptions<T>) {
    if (options == null) options = {};

    // initialize all of the options
    input = el;
    settings = FancySearchSettings.createFromOptions(el, onClearButtonClick, options);

    // create sibling elements
    clearBtn = Dom.create('button', ["class" => settings.classes.clearButton], '\u00D7');
    clearBtn.on('mousedown', settings.onClearButtonClick);

    if (settings.clearBtn) {
      settings.container.append(clearBtn);
    }

    list = new Suggestions(settings.container, el, settings.classes, options.suggestionOptions);

    // apply classes
    input.addClass(settings.classes.input);

    if (input.value.length < 1) {
      input.addClass(settings.classes.inputEmpty);
    }

    // apply event listeners
    input.on('focus', onSearchFocus);
    input.on('blur', onSearchBlur);
    input.on('input', onSearchInput);
    input.on('keydown', cast onSearchKeydown);
  }

  function onSearchFocus(e : Event) {
    // filter and reopen suggestion list if input is not empty
    filterUsingInputValue();
  }

  function onSearchBlur(e: Event) {
    // choosing a suggestion doesn't trigger an `input` event, but it does
    // cause a `blur`, so we check the status of the input here
    checkEmptyStatus();
    list.close();
  }

  function filterUsingInputValue() {
    list.filter(input.value);
    if (input.value.length >= settings.minLength) {
      list.open();
    } else {
      list.close();
    }
  }

  function checkEmptyStatus() {
    if (input.value.length > 0) {
      input.removeClass(settings.classes.inputEmpty);
    } else {
      input.addClass(settings.classes.inputEmpty);
    }
  }

  function onSearchInput(e : Event) {
    // check for content in the input itself
    checkEmptyStatus();

    // then, initially filter given what we already know
    filterUsingInputValue();

    // and kick off a request for more suggestions, if a function was provided
    settings.populateSuggestions.map(function (fn) {
      input.addClass(settings.classes.inputLoading);
      var value = input.value; // cache the value when we make the request

      return fn(value)
        .success(function(result) {
          // only update the suggestion list if input value hasn't changed
          if (value == input.value) list.setSuggestions(result);
        })
        .always(function () input.removeClass(settings.classes.inputLoading));
    });
  }

  function onSearchKeydown(e : KeyboardEvent) {
    e.stopPropagation();

    var code = e.which != null ? e.which : e.keyCode;

    if (settings.keys.closeMenu.contains(code)) {
      list.close();
    } else if (settings.keys.selectionUp.contains(code) && list.isOpen) {
      e.preventDefault();
      list.moveSelectionUp();
    } else if (settings.keys.selectionDown.contains(code) && list.isOpen) {
      e.preventDefault();
      list.moveSelectionDown();
    } else if (settings.keys.selectionChoose.contains(code) && !list.selected.isEmpty()) {
      list.chooseSelectedItem();
    }
  }

  function onClearButtonClick(e : Event) {
    e.preventDefault();
    input.value = "";
    filterUsingInputValue();
  }

  /**
    This static method creates and returns a new FancySearch given a CSS-style
    selector string. This is convenient if you have no other references to the
    input element in your code.
  **/
  public static function createFromSelector<T>(selector : String, options : FancySearchOptions<T>) {
    return new Search(cast js.Browser.document.querySelector(selector), options);
  }

  /**
    This static method creates and returns a new FancySearch given a container
    element surrounding the input that will be used for your FancySearch. This
    assumes that the container has exactly one `input` child.
  **/
  public static function createFromContainer<T>(container : Element, options : FancySearchOptions<T>) {
    options.container = container;
    return new Search(cast container.querySelector('input'), options);
  }
}
