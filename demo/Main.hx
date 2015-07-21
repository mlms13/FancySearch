import fancy.Search;

class Main {
  static function main() {
    var options = {
      limit: 6,
      suggestions : ["Apple", "Banana", "Barley", "Black Bean", "Carrot", "Corn",
        "Cucumber", "Dates", "Eggplant", "Fava Beans", "Kale", "Lettuce", "Lime",
        "Lima Bean", "Mango", "Melon", "Orange", "Peach", "Pear", "Pepper",
        "Potato", "Radish", "Spinach", "Tomato", "Turnip", "Zucchini"]
    };
    var search = Search.createFromSelector('.fancy-container input', options);
  }
}
