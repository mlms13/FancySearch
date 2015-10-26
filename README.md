# Fancy Search

Fancy Search is a [typeahead search](https://en.wikipedia.org/wiki/Incremental_search) implementation for the web. It is written in [Haxe](http://haxe.org/) and compiles to a JavaScript target. The library can be used imported and used directly in Haxe projects, or it can be bundled directly into JavaScript projects using CommonJS (coming soon).

### Getting Started

#### With Haxe

Grab the latest version of the library from Haxelib:

```
haxelib install fancy
```

Import the `Search` module, create a new instance, and away you go.

```haxe
import fancy.Search;

class Main {
  static function main() {
    var search = Search.createFromSelector(".some-selector input", {
      suggestionOptions : {
        suggestions : ["Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn"]
      }
    });
  }
}
```

For a slightly more complete example to get you started, see [the demo in this repository](https://github.com/mlms13/FancySearch/blob/master/demo/Main.hx).

#### With JavaScript

FancySearch has not yet been published to npm. Soon...

### API Documentation

You can find [slightly more complete documentation on RawGit](https://rawgit.com/mlms13/FancySearch/master/docs/pages/fancy/Search.html), but the following should be enough to get you started.

#### Search

The `Search` class is the main entry point. When creating a new instance, you must provide an input element, and you may provide an options object (see `FancySearchOptions` below).

```haxe
var inputEl = js.Browser.document.querySelector("input.my-input");
var mySearch = new Search(cast inputEl, {/* some options... */});
```

Alternatively, if you don't have a handy reference to your input element, you can create a `Search` instance from either a string selector, or from a parent container:

```haxe
var mySearch = Search.createFromSelector("input.my-input", {});
// or...
var container = js.Browser.document.querySelector(".some-div");
var mySearch = Search.createFromContainer(container, {});
```

Regardless of how you create it, you'll end up with a `Search` instance that has only one public field: `mySearch.list`. The `list` is a reference to an instance of `Suggestions` that gets created automatically when you create an instance of `Search`.

#### Suggestions

A `Suggestions` instance is automatically created when you create a `Search`. Because of this, you should never need to interact with the constructor. However, the instance does provide some public function which may be helpful.

- `mySearch.list.setSuggestions(suggestions : Array<String>)`
  Change the list of suggestions after initializing by providing this method with a list of strings.
- `mySearch.list.filter(search : String)`
  Provide this method with a string of text (usually this matches the value of the input), and it will re-filter the suggestion list. Your `Search` instance is already set up to handle this when the input's value changes, but you can call it directly if needed.
- `mySearch.list.open()`, `mySearch.list.close()`
  Open or close the suggestion dropdown list by adding the appropriate class.
- `mySearch.list.selectItem(?key : String)`
  Changes the selection in the suggestion dropdown to a given item. If no key is provided, the selection will be cleared.
- `mySearch.list.moveSelectionUp`, `mySearch.list.moveSelectionDown`
  Changes the selection in the dropdown list to the previous or next list item.
- `mySearch.list.chooseSelectedItem()`
  Calls the optionally-provided `onChooseSelection` function with the input and selection text. This happens on click and when the Enter key is pressed.

#### FancySearchOptions

The following options may be passed to the `Search` constructor. Any of these options may be omitted.

| Name        | Type    | Default             | Description                                                           |
|-------------|---------|---------------------|-----------------------------------------------------------------------|
| `classes`   | Object  |                     | Allows overriding the default class names                             |
| `clearBtn`  | Bool    | true                | Whether to show a clear button when the input is not empty            |
| `container` | Element | input.parentElement | Element containing the search input                                   |
| `keys`      | Object  |                     | Each item can have an array of keycodes that trigger it               |
| `minLength` | Int     | 1                   | How many characters must be entered before suggestions will show      |
| `onClearButtonClick` | Function |           | Action to be performed when the clear button is clicked               |
| `suggestionOptions`  | SuggestionOptions |  | Options that will be passed to the `Suggestions` constructor |

#### SuggestionOptions

The following options may be passed to the `Suggestions` constructor. Any of these options may be omitted.

| Name      | Type     | Default             | Description                                                           |
|-----------|----------|---------------------|-----------------------------------------------------------------------|
| filterFn  | Function |                     | Custom function for filtering search suggestions                      |
| highlightLettersFn | Function |            | Custom function to determine which letters should be highlighted in
                                               the list of suggestions                                               |
| limit     | Int      | 5                   | Max number of suggestions to show in the dropdown                     |
| onChooseSelection | Function |             | Function determines what happens when a selected item is chosen       |
| input     | Element |                      | Provided by `Search`, required for creating `Suggestions`             |
| parent    | Element |                      | Also provided by `Search` and required                                |
| showSearchLiteralItem | Bool | False       | Whether the "Search for <literal text>" suggestion will be shown      |
| searchLiteralPosition | Enum | First       | `First` or `Last` determines where the literal suggestion is placed   |
| searchLiteralValue  | Function |           | Given an `InputElement`, provide the literal search text              |
| searchLiteralPrefix | String | "Search for: " | Text that comes before the literal search text                     |
| suggestions | Array<String> | []           | List of suggestion strings                                            |

### Styling and Customization

Fancy Search has very few opinions when it comes to styles. In fact, most of the basic functionality (showing and hiding the suggestion list, for example) is the result of classes rather than hard-coded styles. This means that without some guidance, Fancy Search probably won't behave the way you expect it to. A [very reasonable CSS example](https://github.com/mlms13/FancySearch/blob/master/bin/basic.css) is provided to give you a starting point.
