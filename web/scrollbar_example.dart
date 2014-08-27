import 'package:react/react_client.dart';
import 'dart:html';
import 'package:react/react.dart';
import 'package:components/selector.dart';
import 'package:components/componentsTypes.dart';
import 'package:components/components.dart';
import 'package:clean_data/clean_data.dart';
import 'package:clean_data/clean_data.dart' as cd;
import 'dart:async';
import 'dart:convert';

void main() {
  setClientConfiguration();

  renderComponent(scrollbarExample({}), querySelector('body'));

}



var scrollbarExample = registerComponent(() => new ScrollbarExample());
class ScrollbarExample extends Component {
  var count = 40;
  var scrollItem = 35;
  render() {
    var _items = [];

    for (var i = 0; i < count; i++) {
      _items.add(div({'className':'list-item'},[
                   span({'className':'team-chart-position'},(i*1234).toString()),
                   span({'className':'long-club-name-text'},'Futbalovy tim cislo $i'),
                   span({'className':'account-type'}),
                   span({'className':'team-zone text-upcase'},'$i'),
                   span({'className':'team-chart-points'},(i*4321).toString())
                 ]));
    }

    return
        div({'style':{"margin":"0 auto", "width":"800px"}},[

          div({"className":"widget-row"},
            div({"className":"widget-column col-1-1"},[
               button({'style': {'position': 'absolute', 'left':400},
                                   'onClick': (e) {count++; redraw();}},
                                   'add'),
            ])
          ),
          div({'className': 'widget widget-chart '}, [
            div({"className":"widget-row"},
              div({"className":"widget-column col-1-1"},[
                div({'style': {'width': 360}}, [
                  scrollableWindow(_items, scrollToPercent: (scrollItem -1)/count),
                ])
              ])
            ),
          ])
      ]);
  }
}
