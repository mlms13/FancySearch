import fancy.Search;

class Main {
  public var search : Search;
  public function new() {
    var options = {
      suggestions : ["Apple", "Banana", "Carrot", "Peach", "Pear", "Turnip"]
    };
    var input = js.Browser.document.querySelector('input.fancify');
    search = new Search(cast input, options);
  }

  static function main() {
    new Main();
  }
}
