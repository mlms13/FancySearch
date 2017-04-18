package fancy.search.util;

import dots.Keys.*;

typedef KeyboardConfig = {
  highlightUp: Array<Int>,
  highlightDown: Array<Int>,
  choose: Array<Int>,
  close: Array<Int>
};

class KeyboardConfigs {
  public static var defaultKeys(default, never): KeyboardConfig = {
    highlightUp: [UP_ARROW, NUMPAD_8],
    highlightDown: [DOWN_ARROW, NUMPAD_2, TAB],
    choose: [ENTER],
    close: [ESCAPE]
  };
}
