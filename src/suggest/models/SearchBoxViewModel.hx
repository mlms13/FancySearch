package suggest.models;

import mithril.M;

typedef SearchBoxOptions = {
  ?placeholder : String
};

class SearchBoxViewModel {
  public var placeholder : String;

  public function new(options : SearchBoxOptions) {
    placeholder = options.placeholder != null ? options.placeholder : '';
  }
}
