import fancy.Search;

import fancy.search.util.Types;
using thx.Arrays;

class Main {
  static function main() {
    var items : Array<Food> = [
      { value: "Apple", aliases: ["Fuji", "Honeycrisp", "Gala", "Granny Smith"] },
      { value: "Bean", aliases: ["Black", "Pinto", "Navy", "Soy", "Northern", "Kidney"] },
      { value: "Chickpea", aliases: ["Garbanzo Bean"] },
      { value: "Corn", aliases: [] },
      { value: "Squash", aliases: ["Summer", "Pumpkin", "Zucchini", "Acorn", "Butternut"] },
      { value: "Leaf Vegetable", aliases: ["Kale", "Spinach", "Romain", "Iceberg", "Lettuce"] },
    ];
    var options : FancySearchOptions<Food> = {
      minLength : 0,
      suggestionOptions : {
        suggestions : items,
        limit : 4,
        suggestionToString : function (sugg) return sugg.value,
        filterFn : function (toString, search, sugg) {
          return sugg.aliases.reduce(function (match, alias) {
            var valFirst = sugg.value.toLowerCase() + " " + alias.toLowerCase(),
                valLast = alias.toLowerCase() + " " + sugg.value.toLowerCase();

            return match || valFirst.indexOf(search) >= 0 || valLast.indexOf(search) >= 0;
          }, false);
        }
      }
    };
    var search = Search.createFromSelector('.fancy-container input', options);
  }
}

typedef Food = {
  value : String,
  aliases : Array<String>
};
