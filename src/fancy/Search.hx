package fancy;

import js.html.Element;
import js.html.InputElement;
import js.html.Event;
import js.html.KeyboardEvent;
import fancy.util.Keys;

using thx.Objects;
using thx.Arrays;
using fancy.util.Dom;

typedef FancySearchClassNames = {
  ?input : String,
  ?inputEmpty : String,
  ?clearButton : String,
  ?suggestionContainer : String,
  ?suggestionsOpen : String,
  ?suggestionsClosed : String,
  ?suggestionsEmpty : String,
  ?suggestionList : String,
  ?suggestionItem : String,
  ?suggestionItemSelected : String
};

typedef FancySearchKeyboardShortcuts = {
  ?closeMenu : Array<Int>,
  ?selectionUp : Array<Int>,
  ?selectionDown : Array<Int>,
  ?selectionChoose : Array<Int>
};

typedef FancySearchOptions = {
  ?classes : FancySearchClassNames,
  ?clearBtn : Bool,
  ?container : Element,
  ?filter : Suggestions.FilterFunction,
  ?keys : FancySearchKeyboardShortcuts,
  ?limit : Int,
  ?onChooseSelection : Suggestions.SelectionChooseFunction,
  ?suggestions : Array<String>,
};

class Search {
  public var input : InputElement;
  public var clearBtn : Element;
  public var list : Suggestions;
  public var classes : FancySearchClassNames;
  public var keys : FancySearchKeyboardShortcuts;

  public function new(el : InputElement, ?options : FancySearchOptions) {
    // initialize all of the options
    input = el;
    options = options != null ? options : {};
    options.classes = options.classes != null ? options.classes : {};
    options.keys = options.keys != null ? options.keys : {};
    if (options.clearBtn == null) options.clearBtn = true;
    if (options.container == null) options.container = input.parentElement;
    if (options.limit == null) options.limit = 5;
    if (options.onChooseSelection == null) options.onChooseSelection = chooseSelection;

    classes = Objects.merge({
      input : 'fs-search-input',
      inputEmpty : 'fs-search-input-empty',
      clearButton : 'fs-clear-input-button',
      suggestionContainer : 'fs-suggestion-container',
      suggestionsOpen : 'fs-suggestion-container-open',
      suggestionsClosed : 'fs-suggestion-container-closed',
      suggestionsEmpty : 'fs-suggestion-container-empty',
      suggestionList : 'fs-suggestion-list',
      suggestionItem : 'fs-suggestion-item',
      suggestionItemSelected : 'fs-suggestion-item-selected'
    }, options.classes);

    keys = Objects.merge({
      closeMenu : [Keys.ESCAPE],
      selectionUp : [Keys.UP],
      selectionDown : [Keys.DOWN],
      selectionChoose : [Keys.ENTER]
    }, options.keys);

    // create sibling elements
    clearBtn = Dom.create('button.${classes.clearButton}', '\u00D7');
    clearBtn.on('mousedown', onClearButtonClick);

    if (options.clearBtn) {
      options.container.appendChild(clearBtn);
    }

    list = new Suggestions({
      filterFn : options.filter,
      limit : options.limit,
      classes : {
        suggestionContainer : classes.suggestionContainer,
        suggestionsOpen : classes.suggestionsOpen,
        suggestionsClosed : classes.suggestionsClosed,
        suggestionsEmpty : classes.suggestionsEmpty,
        suggestionList : classes.suggestionList,
        suggestionItem : classes.suggestionItem,
        suggestionItemSelected : classes.suggestionItemSelected
      },
      onChooseSelection : options.onChooseSelection,
      parent : options.container,
      suggestions : options.suggestions,
    });

    // apply classes
    input.addClass(classes.input).addClass(classes.inputEmpty);

    if (input.value.length < 1) {
      input.addClass(classes.inputEmpty);
    }

    // apply event listeners
    input.on('focus', onSearchFocus);
    input.on('blur', onSearchBlur);
    input.on('input', onSearchInput);
    input.on('keyup', cast onSearchKeyup);
  }

  function onSearchFocus(e : Event) {
    // filter and reopen suggestion list if input is not empty
    if (input.value.length > 0) {
      filterUsingInputValue();
    }
  }

  function onSearchBlur(e: Event) {
    list.close();
  }

  function filterUsingInputValue() {
    if (input.value.length < 1) {
      input.addClass(classes.inputEmpty);
    } else {
      input.removeClass(classes.inputEmpty);
    }
    list.filter(input.value);
    list.open();
  }

  function onSearchInput(e : Event) {
    filterUsingInputValue();
  }

  function onSearchKeyup(e : KeyboardEvent) {
    var code = e.which != null ? e.which : e.keyCode;

    if (keys.closeMenu.contains(code)) {
      list.close();
    } else if (keys.selectionUp.contains(code) && list.isOpen) {
      list.moveSelectionUp();
    } else if (keys.selectionDown.contains(code) && list.isOpen) {
      list.moveSelectionDown();
    } else if (keys.selectionChoose.contains(code) && list.selected != "") {
      list.chooseSelectedItem();
    }
  }

  function onClearButtonClick(e : Event) {
    e.preventDefault();
    input.value = "";
    filterUsingInputValue();
  }

  function chooseSelection(selection : String) {
    input.value = selection;
    input.blur();
  }

  public static function createFromSelector(selector : String, options : FancySearchOptions) {
    return new Search(cast js.Browser.document.querySelector(selector), options);
  }

  public static function createFromContainer(container : Element, options : FancySearchOptions) {
    return new Search(cast container.querySelector('input'), Objects.merge(options, {
      container : container
    }));
  }
}
