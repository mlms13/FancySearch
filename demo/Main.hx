import mithril.M;
import suggest.views.SearchBox;
import suggest.models.SearchBoxViewModel;

class Main implements Component {
  var searchVm : SearchBoxViewModel;
  var search : SearchBox;
  public function new() {}

  public function controller() {
    var options = {
      placeholder : 'Search'
    };
    searchVm = new SearchBoxViewModel(options);
    search = new SearchBox(searchVm);
  }

  public function view() {
    return search.view();
  }

  static function main() {
    M.mount(js.Browser.document.body, new Main());
  }
}
