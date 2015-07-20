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
  ?suggestionList : String,
  ?suggestionItem : String,
  ?suggestionItemMatch : String,
  ?suggestionItemFail : String,
  ?suggestionItemSelected : String
};

typedef FancySearchKeyboardShortcuts = {
  ?closeMenu : Array<Int>,
  ?selectionUp : Array<Int>,
  ?selectionDown : Array<Int>
};

typedef FancySearchOptions = {
  ?container : Element,
  ?suggestions : Array<String>,
  ?filter : Suggestions.FilterFunction,
  ?clearBtn : Bool,
  ?classes : FancySearchClassNames,
  ?keys : FancySearchKeyboardShortcuts
};

class Search {
  public var input : InputElement;
  public var list : Suggestions;
  public var classes : FancySearchClassNames;
  public var keys : FancySearchKeyboardShortcuts;

  public function new(el : InputElement, ?options : FancySearchOptions) {
    var clearBtn : Element;
    var container : Element;

    // initialize all of the options
    input = el;
    options = options != null ? options : {};
    container = options.container != null ? options.container : input.parentElement;
    options.clearBtn = options.clearBtn != null ? options.clearBtn : true;
    options.classes = options.classes != null ? options.classes : {};
    options.keys = options.keys != null ? options.keys : {};

    classes = Objects.merge({
      input : 'fs-search-input',
      inputEmpty : 'fs-search-input-empty',
      clearButton : 'fs-clear-input-button',
      suggestionContainer : 'fs-suggestion-container',
      suggestionsOpen : 'fs-suggestion-container-open',
      suggestionsClosed : 'fs-suggestion-container-closed',
      suggestionList : 'fs-suggestion-list',
      suggestionItem : 'fs-suggestion-item',
      suggestionItemMatch : 'fs-suggestion-item-positive',
      suggestionItemFail : 'fs-suggestion-item-negative',
      suggestionItemSelected : 'fs-suggestion-item-selected'
    }, options.classes);

    keys = Objects.merge({
      closeMenu : [Keys.ESCAPE],
      selectionUp : [Keys.UP],
      selectionDown : [Keys.DOWN]
    }, options.keys);

    // create sibling elements
    clearBtn = Dom.create('button.${classes.clearButton}', '\u00D7');
    clearBtn.on('click', onClearButtonClick);

    if (options.clearBtn) {
      container.appendChild(clearBtn);
    }

    list = new Suggestions({
      parent : container,
      suggestions : options.suggestions,
      filterFn : options.filter,
      classes : {
        suggestionContainer : classes.suggestionContainer,
        suggestionsOpen : classes.suggestionsOpen,
        suggestionsClosed : classes.suggestionsClosed,
        suggestionList : classes.suggestionList,
        suggestionItem : classes.suggestionItem,
        suggestionItemMatch : classes.suggestionItemMatch,
        suggestionItemFail : classes.suggestionItemFail,
        suggestionItemSelected : classes.suggestionItemSelected
      }
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
    // reopen suggestion list if suggestions are filtered, but some exist
    if (list.filtered.length < list.suggestions.length && list.filtered.length > 0) {
      list.open();
    }
  }

  function onSearchBlur(e: Event) {
    list.close();
  }

  function onSearchInput(e : Event) {
    if (input.value.length < 1) {
      input.addClass(classes.inputEmpty);
    } else {
      input.removeClass(classes.inputEmpty);
    }
    list.filter(input.value);
    list.open();
  }

  function onSearchKeyup(e : KeyboardEvent) {
    var code = e.which != null ? e.which : e.keyCode;

    if (keys.closeMenu.contains(code)) {
      list.close();
    } else if (keys.selectionUp.contains(code) && list.isOpen) {
      list.moveSelectionUp();
    } else if (keys.selectionDown.contains(code) && list.isOpen) {
      list.moveSelectionDown();
    }
  }

  function onClearButtonClick(e : Event) {
    input.value = "";
    input.addClass(classes.inputEmpty);
  }
}
