package fancy;

import js.html.Element;
import js.html.InputElement;
import js.html.Event;
import js.html.KeyboardEvent;
import fancy.browser.Keys;
import fancy.search.util.Types;
import fancy.search.*;

using thx.Objects;
using thx.Arrays;
using thx.Strings;
using fancy.browser.Dom;

/**
  The `Search` class is the main entry point. It wires up event handlers along
  with the connection to the suggestion list.

  A new FancySearch can be created using the constructor or one of the static
  factories below. In all cases, some means of accessing an input element must
  be provided, but all options may be omitted.

  Apart from the constructor and factories, no public methods exist on this
  class. It does provide public access to its suggestion list in the form of:

  ```haxe
  myFancySearch.list;
  ```
**/
#if shallow-expose @:expose @:keep #end
class Search<T> {
  public var list(default, null) : Suggestions<T>;
  public var input(default, null) : InputElement;
  var clearBtn : Element;
  var opts : FancySearchOptions<T>;

  /**
    The constructor requires an input element which will be converted into a
    fancy search input (with appropriate event handlers bound to it). All other
    options are not required, but they allow you to modify the behavior of both
    the search input and the suggestion list.
  **/
  public function new(el : InputElement, ?options : FancySearchOptions<T>) {
    // initialize all of the options
    input = el;
    opts = createDefaultOptions(options);
    opts.classes = createDefaultClasses(opts.classes);

    if (opts.suggestionOptions.input == null)
      opts.suggestionOptions.input = input;

    if (opts.suggestionOptions.parent == null)
      opts.suggestionOptions.parent = opts.container;

    opts.keys = Objects.merge({
      closeMenu : [Keys.ESCAPE],
      selectionUp : [Keys.UP],
      selectionDown : [Keys.DOWN, Keys.TAB],
      selectionChoose : [Keys.ENTER]
    }, opts.keys);

    // create sibling elements
    clearBtn = Dom.create('button.${opts.classes.clearButton}', '\u00D7');
    clearBtn.on('mousedown', opts.onClearButtonClick);

    if (opts.clearBtn) {
      opts.container.append(clearBtn);
    }

    list = new Suggestions(opts.suggestionOptions, opts.classes);

    // apply classes
    input.addClass(opts.classes.input);

    if (input.value.length < 1) {
      input.addClass(opts.classes.inputEmpty);
    }

    // apply event listeners
    input.on('focus', onSearchFocus);
    input.on('blur', onSearchBlur);
    input.on('input', onSearchInput);
    input.on('keydown', cast onSearchKeydown);
  }

  function createDefaultOptions<T>(?options : FancySearchOptions<T>) : FancySearchOptions<T> {
    return cast Objects.combine(({
      classes : {},
      keys : {},
      minLength : 1,
      clearBtn : true,
      container : input.parentElement,
      onClearButtonClick : onClearButtonClick,
      suggestionOptions : {}
    } : FancySearchOptions<T>), options == null ? ({} : FancySearchOptions<T>) : options);
  }

  function createDefaultClasses(classes : FancySearchClassNames) {
    return Objects.merge({
      input : 'fs-search-input',
      inputEmpty : 'fs-search-input-empty',
      clearButton : 'fs-clear-input-button',
      inputLoading : 'fs-input-loading',
      suggestionContainer : 'fs-suggestion-container',
      suggestionsOpen : 'fs-suggestion-container-open',
      suggestionsClosed : 'fs-suggestion-container-closed',
      suggestionsEmpty : 'fs-suggestion-container-empty',
      suggestionList : 'fs-suggestion-list',
      suggestionItem : 'fs-suggestion-item',
      suggestionItemSelected : 'fs-suggestion-item-selected'
    }, opts.classes);
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
    if (input.value.length >= opts.minLength) {
      list.open();
    } else {
      list.close();
    }
  }

  function checkEmptyStatus() {
    if (input.value.length > 0) {
      input.removeClass(opts.classes.inputEmpty);
    } else {
      input.addClass(opts.classes.inputEmpty);
    }
  }

  function onSearchInput(e : Event) {
    // check for content in the input itself
    checkEmptyStatus();

    // then, initially filter given what we already know
    filterUsingInputValue();

    // and kick off a request for more suggestions, if a function was provided
    if (opts.populateSuggestions != null) {
      input.addClass(opts.classes.inputLoading);

      opts.populateSuggestions(input.value)
        .success(list.setSuggestions)
        .always(function () input.removeClass(opts.classes.inputLoading));
    }
  }

  function onSearchKeydown(e : KeyboardEvent) {
    var code = e.which != null ? e.which : e.keyCode;

    if (opts.keys.closeMenu.contains(code)) {
      list.close();
    } else if (opts.keys.selectionUp.contains(code) && list.isOpen) {
      e.preventDefault();
      list.moveSelectionUp();
    } else if (opts.keys.selectionDown.contains(code) && list.isOpen) {
      e.preventDefault();
      list.moveSelectionDown();
    } else if (opts.keys.selectionChoose.contains(code) && !list.selected.isEmpty()) {
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
