import fancy.Search;

class Main {
  static function main() {
    var options = {
      suggestions : ["Apple", "Banana", "Carrot", "Peach", "Pear", "Turnip"]
    };
    var input = js.Browser.document.querySelector('input.fancify');
    var search = new Search(cast input, options);
  }
}
