package fancy.search.config;

import haxe.ds.Option;
import thx.Lazy;
import dots.Keys;

typedef RendererConfig<Sug, Filter, El> = {
  classes: ClassNameConfig,
  keys: KeyboardConfig,
  elements: ElementConfig<El>,
  renderSuggestion: Sug -> Filter -> El
};

typedef KeyboardConfig = {
  highlightUp: KeyWithModifiers -> Bool,
  highlightDown: KeyWithModifiers -> Bool,
  choose: KeyWithModifiers -> Bool,
  close: KeyWithModifiers -> Bool
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
