package suggest.views;

import mithril.M;
import suggest.models.SearchBoxViewModel;

class SearchBox implements View {
  var vm : SearchBoxViewModel;
  public function new(vm : SearchBoxViewModel) {
    this.vm = vm;
  }

  public function view() : ViewOutput {
    return INPUT({
      placeholder : vm.placeholder
    });
  }
}
