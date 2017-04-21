package fancy.search.config;

import haxe.ds.Option;
import thx.Lazy;

typedef RendererConfig<Sug, El> = {
  classes: ClassNameConfig,
  keys: KeyboardConfig,
  // parseInput: String -> Option<Filter>,
  // renderInput: Option<Filter> -> String,
  clearButton: Option<Lazy<El>>,
  renderSuggestion: Sug -> El
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
  containerTooShort: String,
  containerNoResults: String,
  containerLoading: String,
  containerFailed: String,
  list: String,
  label: String,
  item: String,
  itemHighlighted: String
};
