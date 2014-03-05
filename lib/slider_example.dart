library slider_example;

import 'package:react/react.dart';
import 'components.dart';

var sliderExample = registerComponent(() => new SliderExample());

class SliderExample extends Component {
  var count = 3;

  render() {
    var _items = [];

    for (var i = 0; i < count; i++) {
      _items.add(div({'className':'list-item'},[
                   span({'className':'team-chart-position'},(i*1234).toString()),
                   span({'className':'long-club-name-text'},'Futbalovy tim cislo $i'),
                   span({'className':'account-type'}),
                   span({'className':'team-zone text-upcase'},'abcdef $i'),
                   span({'className':'team-chart-points'},(i*4321).toString())
                 ]));
    }

    return
        div({'style': {'width': 360}}, [
            scrollableWindow(_items),
            button({'style': {'position': 'absolute', 'left':400},
                    'onClick': (e) {count++; redraw();}},
                   'add'),
        ]);

  }
}
