import fancy.Search;
import dots.Dom;

class Main {
  static function main() {
    var options = {
      minLength : 0,
      suggestionOptions : {
        suggestions : [
          "Amazon",
          "Angellist",
          "Apple",
          "Facebook",
          "Foursquare",
          "Github",
          "Google",
          "Linkedin",
          "Twitter",
          "Vimeo",
        ],
        limit : 6,
        showSearchLiteralItem : true,
        suggestionToElement : function(v : String) {
          return Dom.create('span', [
            Dom.create('i.fa.fa-${v.toLowerCase()}[style=color:#000]'),
            Dom.create('span.fs-suggestion-highlight[style=color:#999]', ' $v')
          ]);
        }
      }
    };
    var search = Search.createFromSelector('.fancy-container input', options);
  }
}
