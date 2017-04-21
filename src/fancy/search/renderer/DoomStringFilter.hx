package fancy.search.renderer;

import doom.html.Html.*;
import doom.core.VNode;
import fancy.Search;
import fancy.search.config.RendererConfig;

class DoomStringFilter<Sug, Value> extends doom.html.Component<{ search: Search<Sug, String, Value>, cfg:  RendererConfig<Sug, VNode>}> {
  public override function render() {
    return div();
  }
}
