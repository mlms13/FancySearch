package fancy.search;

import haxe.ds.Option;
import dots.Keys;
import js.html.Element;
import js.html.InputElement;
import fancy.search.util.Types;
using thx.Options;

typedef FancySearchClasses = {
  input: String,
  inputEmpty: String,
  inputLoading: String,
  clearButton: String,
  suggestionContainer: String,
  suggestionsOpen: String,
  suggestionsClosed: String,
  suggestionsEmpty: String,
  suggestionList: String,
  suggestionItem: String,
  suggestionItemSelected: String,
  suggestionHighlight: String,
  suggestionHighlighted: String
};

typedef KeyboardShortcuts = {
  closeMenu: Array<Int>,
  selectionUp: Array<Int>,
  selectionDown: Array<Int>,
  selectionChoose: Array<Int>
};

class FancySearchSettings<T> {
  public var classes(default, null): FancySearchClasses;
  public var clearBtn(default, null): Bool;
  public var container(default, null): Element;
  public var keys: KeyboardShortcuts;
  public var minLength(default, null): Int;
  public var onClearButtonClick(default, null): EventHandler;
  public var populateSuggestions(default, null): Option<String -> thx.promise.Promise<Array<T>>>;

  function new(classes, clearBtn, container, keys, minLength, onClearButtonClick, populateSuggestions) {
    this.classes = classes;
    this.clearBtn = clearBtn;
    this.container = container;
    this.keys = keys;
    this.minLength = minLength;
    this.onClearButtonClick = onClearButtonClick;
    this.populateSuggestions = populateSuggestions;
  }

  static function classesFromOptions(?opts: FancySearchClassOptions): FancySearchClasses {
    if (opts == null) opts = {};

    return {
      input: opts.input != null ? opts.input : "fs-search-input",
      inputEmpty: opts.inputEmpty != null ? opts.inputEmpty : "fs-search-input-empty",
      inputLoading: opts.inputLoading != null ? opts.inputLoading : "fs-search-input-loading",
      clearButton: opts.clearButton != null ? opts.clearButton : "fs-clear-input-button",
      suggestionContainer: opts.suggestionContainer != null ? opts.suggestionContainer : "fs-suggestion-container",
      suggestionsOpen: opts.suggestionsOpen != null ? opts.suggestionsOpen : "fs-suggestion-container-open",
      suggestionsClosed: opts.suggestionsClosed != null ? opts.suggestionsClosed : "fs-suggestion-container-closed",
      suggestionsEmpty: opts.suggestionsEmpty != null ? opts.suggestionsEmpty : "fs-suggestion-container-empty",
      suggestionList: opts.suggestionList != null ? opts.suggestionList : "fs-suggestion-list",
      suggestionItem: opts.suggestionItem != null ? opts.suggestionItem : "fs-suggestion-item",
      suggestionItemSelected: opts.suggestionItemSelected != null ? opts.suggestionItemSelected : "fs-suggestion-item-selected",
      suggestionHighlight: opts.suggestionHighlight != null ? opts.suggestionHighlight : "fs-suggestion-highlight",
      suggestionHighlighted: opts.suggestionHighlighted != null ? opts.suggestionHighlighted : "fs-suggestion-highlighted"
    };
  }

  static function keyboardShortcutsFromOptions(?opts: FancySearchKeyboardShortcuts): KeyboardShortcuts {
    if (opts == null) opts = {};

    return {
      closeMenu: opts.closeMenu != null ? opts.closeMenu : [Keys.ESCAPE],
      selectionUp: opts.selectionUp != null ? opts.selectionUp : [Keys.UP_ARROW],
      selectionDown: opts.selectionDown != null ? opts.selectionDown : [Keys.DOWN_ARROW, Keys.TAB],
      selectionChoose: opts.selectionChoose != null ? opts.selectionChoose : [Keys.ENTER]
    };
  }

  public static function createFromOptions<T>(input: InputElement, clrBtnClick: EventHandler, ?opts: FancySearchOptions<T>): FancySearchSettings<T> {
    if (opts == null) opts = {};

    return new FancySearchSettings(
      classesFromOptions(opts.classes),
      opts.clearBtn != null ? opts.clearBtn : true,
      opts.container != null ? opts.container :
        Options.ofValue(input.parentElement).getOrThrow(),
      keyboardShortcutsFromOptions(opts.keys),
      opts.minLength != null ? opts.minLength : 1,
      opts.onClearButtonClick != null ? opts.onClearButtonClick : clrBtnClick,
      Options.ofValue(opts.populateSuggestions)
    );
  }
}
