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
          trace("SUGGESTION ", v);
          return Dom.create('i.fa.fa-${v.toLowerCase()}');
        }
      }
    };
    var search = Search.createFromSelector('.fancy-container input', options);
  }
}
