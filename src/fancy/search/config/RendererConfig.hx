package fancy.search.config;

import haxe.ds.Option;
import thx.Lazy;

typedef RendererConfig<Sug, Filter, El> = {
  classes: ClassNameConfig,
  keys: KeyboardConfig,
  elements: ElementConfig<El>,
  renderSuggestion: Sug -> Filter -> El
};

typedef KeyboardConfig = {
  highlightUp: Array<Int>,
  highlightDown: Array<Int>,
  choose: Array<Int>,
  close: Array<Int>
};

typedef ClassNameConfig = {
  input: String,
  container: String,
  containerClosed: String,
  containerOpen: String,
  containerNotAllowed: String,
  containerNoResults: String,
  containerLoading: String,
  containerFailed: String,
  list: String,
  label: String,
  item: String,
  itemHighlighted: String
};

typedef ElementConfig<El> = {
  clearButton: Option<Lazy<El>>,
  failedCondition: Option<String -> El>,
  loading: Option<Lazy<El>>,
  noResults: Option<Lazy<El>>,
  failed: Option<Lazy<El>>
};
