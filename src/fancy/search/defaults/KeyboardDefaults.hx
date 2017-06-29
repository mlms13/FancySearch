package fancy.search.defaults;

import dots.Keys;
using thx.Arrays;
import fancy.search.config.RendererConfig;

class KeyboardDefaults {
  public static var defaults(default, never): KeyboardConfig = {
    highlightUp: keyWithMod -> switch keyWithMod {
      case { key: NonPrinting(UpArrow) }: true;
      case { key: NamedPrinting(Tab), modifiers: m } if (m.contains(Shift)): true;
      case _: false;
    },
    highlightDown: keyWithMod -> switch keyWithMod {
      case { key: NonPrinting(DownArrow) }: true;
      case { key: NamedPrinting(Tab), modifiers: m } if (!m.contains(Shift)): true;
      case _: false;
    },
    choose: keyWithMod -> switch keyWithMod {
      case { key: NamedPrinting(Enter) }: true;
      case _: false;
    },
    close: keyWithMod -> switch keyWithMod {
      case { key: NonPrinting(Escape) }: true;
      case _: false;
    }
  };
}
