package fancy.search.defaults;

import dots.Keys.*;
import fancy.search.config.RendererConfig;

class KeyboardDefaults {
  public static var defaults(default, never): KeyboardConfig = {
    highlightUp: [UP_ARROW, NUMPAD_8],
    highlightDown: [DOWN_ARROW, NUMPAD_2, TAB],
    choose: [ENTER],
    close: [ESCAPE]
  };
}
