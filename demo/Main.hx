import fancy.Search;

class Main {
  static function main() {
    var options = {
      suggestions : ["Apple", "Banana", "Carrot", "Peach", "Pear", "Turnip"]
    };
    var search = Search.createFromSelector('.fancy-container input', options);
  }
}
