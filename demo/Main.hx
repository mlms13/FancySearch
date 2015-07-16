import suggest.FancySearch;

class Main {
  public var search : FancySearch;
  public function new() {
    var options = {
      suggestions : ["Apple", "Banana", "Carrot", "Peach", "Pear", "Turnip"]
    };
    var input = js.Browser.document.querySelector('input.fancify');
    search = new FancySearch(cast input, options);
  }

  static function main() {
    new Main();
  }
}
