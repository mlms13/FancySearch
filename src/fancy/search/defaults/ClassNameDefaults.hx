package fancy.search.defaults;

import fancy.search.config.RendererConfig;

class ClassNameDefaults {
  public static var prefix(default, never) = "fs-suggestion";
  public static var containerPrefix(default, never) = prefix + "-container";
  public static var defaults(default, never): ClassNameConfig = {
    input: "fs-search",
    container: containerPrefix,
    containerClosed: containerPrefix + "-closed",
    containerOpen: containerPrefix + "-open",
    containerTooShort: containerPrefix + "-too-short",
    containerNoResults: containerPrefix + "-empty",
    containerLoading: containerPrefix + "-loading",
    containerFailed: containerPrefix + "-failed",
    list: prefix + "-list",
    label: prefix + "-label",
    item: prefix + "-item",
    itemHighlighted: prefix + "-item-highlighted"
  };
}
