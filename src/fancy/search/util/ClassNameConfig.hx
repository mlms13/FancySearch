package fancy.search.util;

typedef ClassNameConfig = {
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

class ClassNameConfigs {
  public static var prefix(default, never) = "fs-suggestion";
  public static var containerPrefix(default, never) = prefix + "-container";
  public static var defaultClasses(default, never): ClassNameConfig = {
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
