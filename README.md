# Fancy Search

Fancy Search is a [typeahead search](https://en.wikipedia.org/wiki/Incremental_search) implementation for the web. It is written in [Haxe](http://haxe.org/) and compiles to a JavaScript target. The library can be imported and used directly in Haxe projects, or it can be bundled into JavaScript projects using CommonJS (coming soon).

The result may look something like the following:

![Fancy Search screen capture](https://cloud.githubusercontent.com/assets/1105543/10721933/85faa584-7b70-11e5-8407-3b451bacdb9d.gif)

For live demos, see:

- [Simple string filtering](https://rawgit.com/mlms13/FancySearch/master/demo/00.string-list/www/index.html)
- [More complex object filtering](https://rawgit.com/mlms13/FancySearch/master/demo/01.search-objects/www/index.html)

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

For a slightly larger example, see [the demo in this repository](https://github.com/mlms13/FancySearch/blob/master/demo/00.string-list/src/Main.hx).

#### With JavaScript

FancySearch has not yet been published to npm. Soon...

### API Documentation

You can find [complete documentation on RawGit](https://rawgit.com/mlms13/FancySearch/master/docs/pages/fancy/Search.html), but the following should be enough to get started.

### Styling and Customization

Fancy Search is not opinionated when it comes to styles. In fact, most of the basic functionality (showing and hiding the suggestion list, for example) is the result of changing classes rather than hard-coded styles. This means that without some style guidance, Fancy Search probably won't behave the way you expect it to. A [simple CSS example](https://github.com/mlms13/FancySearch/blob/master/bin/basic.css) is provided to give you a starting point.
