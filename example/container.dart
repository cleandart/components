library item;

import 'package:react/react.dart';
import 'scrollbar_example.dart';
import 'selector_example.dart';
import 'slider_example.dart';

// add new component examples here
var componentExamples = {
  'selector': selectorExample,
  'scrollbar': scrollbarExample,
  'slider': sliderExample,
};

var container = registerComponent(() => new ComponentContainer());

class ComponentContainer extends Component {
  var selected = null;
  select(clicked) {
    selected = clicked;
    redraw();
  }

  render() {
    var buttons = componentExamples.keys
        .map((cName) => button({'onClick': (_) => select(cName)}, cName));
    var render = componentExamples[selected];
    var content = (render == null) ? 'Choose some component.' : render({});

    return
        div({}, [
        div({'key' : 'dummy', 'style' : {'height' : '150px'}}, buttons),
       content
    ]);

  }
}
